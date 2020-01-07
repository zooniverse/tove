class TranscriptionSerializer
  include FastJsonapi::ObjectSerializer

  attributes :workflow_id, :group_id, :text, :status, :flagged
  belongs_to :workflow
end
