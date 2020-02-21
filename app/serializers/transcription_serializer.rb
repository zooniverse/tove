class TranscriptionSerializer
  include FastJsonapi::ObjectSerializer

  attributes :workflow_id, :group_id, :status, :flagged, :updated_at, :updated_by
  attribute :text, if: proc { |_record, params|
    params && params[:is_collection] == false
  }
  belongs_to :workflow
end
