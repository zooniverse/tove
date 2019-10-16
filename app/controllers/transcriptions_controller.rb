class TranscriptionsController < ApplicationController
  def index
    @transcriptions = Transcription.all
    jsonapi_render(@transcriptions, allowed_filters)
  end

  private

  def allowed_filters
    [:subject_id, :workflow_id, :group_id, :flagged]
  end
end
