class TranscriptionsController < ApplicationController
  include JSONAPI::Errors
  include JSONAPI::Deserialization

  def index
    @transcriptions = Transcription.all
    jsonapi_render(@transcriptions, allowed_filters)
  end

  def update
    @transcription = Transcription.find(params[:id])
    raise ActionController::UnpermittedParameters if type_invalid?
    @transcription.update(update_attrs)
    render jsonapi: @transcription
  end

  private

  def update_attrs
    params.require(:data)
          .require(:attributes)
          .permit(:text, :flagged, :status)
  end

  def type_invalid?
    params[:data][:type] != "transcriptions"
  end

  def allowed_filters
    [:subject_id, :workflow_id, :group_id, :flagged]
  end
end
