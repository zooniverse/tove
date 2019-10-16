class TranscriptionSerializer
  include FastJsonapi::ObjectSerializer

  attributes :subject_id, :workflow_id, :group_id, :text, :status, :flagged
  belongs_to :workflow
end
