class TranscriptionSerializer
  include FastJsonapi::ObjectSerializer

  attributes :workflow_id, :group_id, :status, :flagged, :updated_at, :updated_by, :internal_id, :total_lines, :total_pages, :low_consensus_lines, :parameters, :reducer, :frame_order
  attribute :text, if: proc { |_record, params|
    params[:serialize_text] == true
  }
  belongs_to :workflow

  attribute :locked_by do |transcription|
    transcription.locked_by if transcription.locked?
  end
end
