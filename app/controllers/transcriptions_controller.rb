class TranscriptionsController < ApplicationController
  include JSONAPI::Deserialization

  def index
    @transcriptions = policy_scope(Transcription)
    jsonapi_render(@transcriptions, allowed_filters)
  end

  def show
    @transcription = Transcription.find(params[:id])
    authorize @transcription
    render jsonapi: @transcription
  end

  def update
    @transcription = Transcription.find(params[:id])
    authorize @transcription
    raise ActionController::BadRequest if type_invalid?

    if approve?
      policy = TranscriptionPolicy.new(current_user, @transcription)
      unless policy.approver? || policy.admin?
        raise Pundit::NotAuthorizedError
      end
    end

    @transcription.update!(update_attrs)
    render jsonapi: @transcription
  end

  private

  def update_attrs
    jsonapi_deserialize(params)
  end

  def type_invalid?
    params[:data][:type] != "transcriptions"
  end

  def approve?
    update_attrs["status"] == "approved"
  end

  def allowed_filters
    [:id, :workflow_id, :group_id, :flagged, :status]
  end
end
