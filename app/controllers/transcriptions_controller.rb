class TranscriptionsController < ApplicationController
  include JSONAPI::Deserialization

  class TranscriptionLockedError < StandardError; end
  class NoExportableTranscriptionsError < StandardError; end
  class ValidationError < StandardError; end
  class ActionForbiddenError < StandardError; end

  rescue_from ValidationError, with: :render_jsonapi_bad_request
  rescue_from ActionForbiddenError, with: :render_jsonapi_not_authorized

  before_action :status_filter_to_int, only: :index

  def index
    @transcriptions = policy_scope(Transcription)
    jsonapi_render(@transcriptions, allowed_filters)
  end

  def show
    @transcription = Transcription.find(params[:id])
    authorize @transcription

    if TranscriptionPolicy.new(current_user, @transcription).has_update_rights?
      @transcription.lock(current_user)
    end

    response.set_header('Last-Modified', @transcription.updated_at.rfc2822)
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

    render jsonapi: @transcription
  end

  def unlock
    @transcription = Transcription.find(params[:id])
    authorize @transcription, :update?
    if @transcription.locked_by != current_user.login
      raise ActionForbiddenError,
            "You are not allowed to unlock this transcription. Transcription is locked by #{@transcription.locked_by} and can only be unlocked by this user."
    end

    @transcription.update!(locked_by: nil, lock_timeout: nil)
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

    @transcriptions = Transcription.where(group_id: params[:group_id], workflow_id: params[:workflow_id])

    if @transcriptions.empty?
      raise NoExportableTranscriptionsError, "No exportable transcriptions found for group id '#{params[:group_id]}'"
    end

    data_storage = DataExports::DataStorage.new
    data_storage.zip_group_files(@transcriptions) do |zip_file|
      send_export_file zip_file
    end
  end

  private

  def update_attrs
    @update_attrs ||= jsonapi_deserialize(params)
  end

  def validate_update
    raise ActionController::BadRequest if type_invalid?
    raise ActionController::BadRequest unless whitelisted_attributes?
    raise ActiveRecord::StaleObjectError unless @transcription.fresh?(if_unmodified_since)
    if @transcription.locked_by_different_user? current_user
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
    if params[:filter]
      params[:filter].each do |key, value|
        # filter key is comprised of <filterterm>_<relationship>
        # e.g. id_eq, status_in, etc - check if filter term is status
        if key.split('_').first == 'status'
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
    end
  end

  def type_invalid?
    params[:data][:type] != "transcriptions"
  end

  def whitelisted_attributes?
    update_attrs.keys.all? { |key| update_attr_whitelist.include? key }
  end

  def update_attr_whitelist
    ["flagged", "text", "status"]
  end

  def allowed_filters
    [:id, :workflow_id, :group_id, :flagged, :status, :internal_id]
  end

  def approving?
    update_attrs["status"] == "approved"
  end

  def jsonapi_serializer_params
    {
      serialize_text: action_name == 'show'
    }
  end

  def if_unmodified_since
    since = request.headers['If-Unmodified-Since']

    if since.blank?
      raise ValidationError, 'Missing header "If-Unmodified-Since", action cannot be performed.'
    end

    begin
      Time.rfc2822(since)
    rescue
      raise ValidationError, 'The date found in "If-Unmodified-Since" is not properly formed and cannot be processed.'
    end
  end
end
