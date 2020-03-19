class TranscriptionSerializer
  include FastJsonapi::ObjectSerializer

  attributes :workflow_id, :group_id, :status, :flagged, :updated_at, :updated_by, :internal_id, :total_lines, :total_pages, :low_consensus_lines, :parameters, :reducer
  attribute :text, if: proc { |_record, params|
    params[:serialize_text] == true
  }
  belongs_to :workflow
end
