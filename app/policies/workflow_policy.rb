class WorkflowPolicy < ApplicationPolicy
  delegate :editor?, :approver?, :viewer?, to: :project_policy

  def project_policy
    ProjectPolicy.new(user, projects)
  end

  def projects
    records.compact.collect(&:project).uniq.compact
  end

  class Scope < Scope
    def resolve
      viewer_policy_scope
    end
  end
end