class WorkflowSerializer
  include FastJsonapi::ObjectSerializer

  attributes :display_name, :total_transcriptions
  attribute :groups, &:transcription_group_data
  belongs_to :project
end
