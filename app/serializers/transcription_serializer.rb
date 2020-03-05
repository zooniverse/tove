class TranscriptionSerializer
  include FastJsonapi::ObjectSerializer

  attributes :workflow_id, :group_id, :text, :status, :flagged, :updated_at, :updated_by
  belongs_to :workflow

  attribute :locked_by do |transcription|
    transcription.locked_by if transcription.lock_timeout? &&
                               DateTime.now < transcription.lock_timeout
  end
end
