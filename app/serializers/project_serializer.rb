class ProjectSerializer
  include FastJsonapi::ObjectSerializer

  attributes :slug
  has_many :workflows
end
