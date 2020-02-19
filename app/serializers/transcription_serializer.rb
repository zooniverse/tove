class TranscriptionSerializer
  include FastJsonapi::ObjectSerializer

  attributes :workflow_id, :group_id, :text, :status, :flagged, :updated_at, :updated_by
  belongs_to :workflow
end
