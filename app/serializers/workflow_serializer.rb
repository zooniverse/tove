class WorkflowSerializer
  include FastJsonapi::ObjectSerializer

  attributes :display_name, :groups
  belongs_to :project
end
