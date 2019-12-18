class WorkflowSerializer
  include FastJsonapi::ObjectSerializer

  attributes :display_name, :groups, :total_transcriptions
  belongs_to :project
end
