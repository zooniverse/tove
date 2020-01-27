class WorkflowPolicy < ApplicationPolicy
  delegate :editor?, :approver?, :viewer?, to: :project_policy

  def project_policy
    ProjectPolicy.new(user, Project.where(id: records.pluck(:project_id).uniq))
  end

  class Scope < Scope
    def resolve
      viewer_policy_scope
    end

    def viewer_policy_scope
      if user.admin?
        scope.all
      elsif user
        scope.joins(:project).where project_id: role_checker.viewer_project_ids
      end
    end
  end
end
