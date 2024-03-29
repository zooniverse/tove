class TranscriptionsController < ApplicationController
  include JSONAPI::Deserialization

  class TranscriptionLockedError < StandardError; end
  class NoExportableTranscriptionsError < StandardError; end
  class ValidationError < StandardError; end
  class LockedByAnotherUserError < StandardError; end

  rescue_from ValidationError, with: :render_jsonapi_bad_request
  rescue_from LockedByAnotherUserError, with: :render_jsonapi_not_authorized
  rescue_from NoExportableTranscriptionsError, with: :render_jsonapi_not_found
  rescue_from Encoding::UndefinedConversionError, with: :render_jsonapi_internal_server_error

  before_action :status_filter_to_int, only: :index

  def index
    @transcriptions = policy_scope(Transcription)
    jsonapi_render(@transcriptions, allowed_filters)
  end

  def show
    @transcription = Transcription.find(params[:id])
    authorize @transcription

    if @transcription.unlocked? && transcription_policy.has_update_rights?
      @transcription.lock!(current_user)
    end

    if @transcription.status == 'unseen'
      @transcription.status = 'in_progress'
      @transcription.save!
    end

    response.last_modified = @transcription.updated_at
    render jsonapi: @transcription
  end

  def update
    @transcription = Transcription.find(params[:id])
    validate_update
    authorize_update

    update_attrs['updated_by'] = current_user.login
    update_attrs['locked_by'] = current_user.login
    update_attrs['lock_timeout'] = DateTime.now + 3.hours

    @transcription.update!(update_attrs)

    if @transcription.status_previously_changed?
      if approving?
        @transcription.upload_files_to_storage
      else
        @transcription.remove_files_from_storage
      end
    end

    response.last_modified = @transcription.updated_at
    render jsonapi: @transcription
  end

  def unlock
    @transcription = Transcription.find(params[:id])
    authorize @transcription, :update?
    if @transcription.locked_by_different_user? current_user.login
      raise LockedByAnotherUserError,
            "You are not allowed to unlock this transcription. Transcription is locked by #{@transcription.locked_by} and can only be unlocked by this user."
    end

    @transcription.unlock!
  end

  def export
    @transcription = Transcription.find(params[:id])
    authorize @transcription

    data_storage = DataExports::DataStorage.new
    data_storage.zip_transcription_files(@transcription) do |zip_file|
      send_export_file zip_file
    end
  end

  def export_group
    workflow = Workflow.find(params[:workflow_id])
    authorize workflow

    # Load attached export files as an include with a single extra query
    @transcriptions = Transcription.with_attached_export_files.where(group_id: params[:group_id], workflow_id: params[:workflow_id])

    if @transcriptions.empty?
      raise NoExportableTranscriptionsError, "No exportable transcriptions found for group id '#{params[:group_id]}'"
    end

    data_storage = DataExports::DataStorage.new
    data_storage.zip_group_files(@transcriptions) do |zip_file|
      send_export_file zip_file
    end
  end

  def jsonapi_render(collection, filters)
    jsonapi_filter(collection, filters) do |filtered|
      @approved_count = filtered.result.where(status: 'approved').count
      jsonapi_paginate(filtered.result) do |paginated|
        render jsonapi: paginated
      end
    end
  end

  private

  def jsonapi_meta(resources)
    return super(resources) if @approved_count.nil?

    approved_count_hash = { approved_count: @approved_count }
    super(resources, approved_count_hash)
  end

  def update_attrs
    @update_attrs ||= jsonapi_deserialize(params)
  end

  def validate_update
    raise ActionController::BadRequest if type_invalid?
    raise ActionController::BadRequest unless whitelisted_attributes?
    unless @transcription.is_fresh?(if_unmodified_since)
      raise ActiveRecord::StaleObjectError
    end
    if @transcription.locked_by_different_user? current_user.login
      raise TranscriptionLockedError, "Transcription locked by #{@transcription.locked_by}"
    end
  end

  def authorize_update
    if approving?
      authorize @transcription, :approve?
    else
      authorize @transcription
    end
  end

  # Ransack filtering doesn't handle filtering by enum term (e.g. 'ready'),
  # so we must translate status terms to their integer value if they're present
  def status_filter_to_int
    params[:filter]&.each do |key, value|
      # filter key is comprised of <filterterm>_<relationship>
      # e.g. id_eq, status_in, etc - check if filter term is status
      next unless key.split('_').first == 'status'

      # split status terms in case there is a list of them
      status_terms = value.split(',')
      status_enum_values = []

      # for each status term, try to convert to enum value,
      # and add to list of converted enum values
      status_terms.each do |term|
        enum_value = Transcription.statuses[term]
        status_enum_values.append(enum_value.to_s) if enum_value
      end

      # if list of converted enum values is not empty,
      # update params to reflect converted values
      unless status_enum_values.empty?
        params[:filter][key] = status_enum_values.join(',')
      end
    end
  end

  def type_invalid?
    params[:data][:type] != 'transcriptions'
  end

  def whitelisted_attributes?
    update_attrs.keys.all? { |key| update_attr_whitelist.include? key }
  end

  def approving?
    update_attrs['status'] == 'approved'
  end

  def allowed_filters
    %i[id workflow_id group_id flagged status internal_id updated_at updated_by low_consensus_lines total_pages total_lines]
  end

  def update_attr_whitelist
    %w[flagged text status reducer parameters frame_order]
  end

  def jsonapi_serializer_params
    {
      serialize_text: action_name == 'show'
    }
  end

  def if_unmodified_since
    since = request.headers['If-Unmodified-Since']

    if since.blank?
      raise ValidationError, "You must supply the 'If-Unmodified-Since' header and it must contain the resource's GET request 'Last-Modified' header value."
    end

    begin
      Time.rfc2822(since)
    rescue StandardError
      raise ValidationError, "#{since}: the value supplied in 'If-Unmodified-Since' header cannot be processed. The 'If-Unmodified-Since' header must contain the resource's GET request 'Last-Modified' header value."
    end
  end

  def transcription_policy
    @policy ||= TranscriptionPolicy.new(current_user, @transcription)
  end
end
