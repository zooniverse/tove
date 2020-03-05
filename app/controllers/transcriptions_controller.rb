class TranscriptionsController < ApplicationController
  include JSONAPI::Deserialization

  class TranscriptionLockedError < StandardError; end

  before_action :status_filter_to_int, only: :index

  def index
    @transcriptions = policy_scope(Transcription)
    jsonapi_render(@transcriptions, allowed_filters)
  end

  def show
    @transcription = Transcription.find(params[:id])
    authorize @transcription

    if TranscriptionPolicy.new(current_user, @transcription).has_update_rights?
      lock_transcription
    end

    render jsonapi: @transcription
  end

  def update
    @transcription = Transcription.find(params[:id])
    raise ActionController::BadRequest if type_invalid?
    raise ActionController::BadRequest unless whitelisted_attributes?
    raise ActiveRecord::StaleObjectError unless fresh?
    raise TranscriptionLockedError, "Transcription locked by #{@transcription.locked_by}" if locked?

    if approve?
      authorize @transcription, :approve?
    else
      authorize @transcription
    end

    update_attrs['updated_by'] = current_user.login
    update_attrs['locked_by'] = current_user.login
    update_attrs['lock_timeout'] = DateTime.now + 3.hours

    @transcription.update!(update_attrs)
    render jsonapi: @transcription
  end

  def unlock
    @transcription = Transcription.find(params[:id])
    authorize @transcription, :update?

    return unless @transcription.locked_by == current_user.login

    @transcription.update!(locked_by: nil, lock_timeout: nil)
  end

  private

  def update_attrs
    @update_attrs ||= jsonapi_deserialize(params)
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

  def approve?
    update_attrs["status"] == "approved"
  end

  def fresh?
    # the 'If-Unmodified-Since' datetime will be sent over by client with ISO 8601 format, 3 digits of fractional seconds
    @transcription.updated_at.iso8601(3) == request.headers['If-Unmodified-Since']
  end

  def locked?
    @transcription.lock_timeout &&
      DateTime.now < @transcription.lock_timeout &&
      current_user.login != @transcription.locked_by
  end

  def lock_transcription
    @transcription.update!(locked_by: current_user.login, lock_timeout: DateTime.now + 3.hours)
  end

  def allowed_filters
    [:id, :workflow_id, :group_id, :flagged, :status, :internal_id]
  end

  def update_attr_whitelist
    ["flagged", "text", "status"]
  end
end
