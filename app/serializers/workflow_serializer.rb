class WorkflowSerializer
  include FastJsonapi::ObjectSerializer

  attributes :display_name
  belongs_to :project
end
