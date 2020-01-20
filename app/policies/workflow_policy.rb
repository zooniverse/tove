class WorkflowPolicy < ApplicationPolicy
  delegate :editor?, :approver?, :viewer?, to: :project_policy

  def project_policy
    ProjectPolicy.new(user, projects)
  end

  def projects
    records.collect(&:project).uniq
  end

  class Scope < Scope
    def resolve
      viewer_policy_scope
    end

    def viewer_policy_scope
      if user.admin?
        scope.all
      elsif user
        scope.joins(:project).where project_id: viewer_project_ids
      end
    end
  end
end