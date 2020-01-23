class ProjectPolicy < ApplicationPolicy
  def editor?
    role_checker.can_edit?
  end

  def approver?
    role_checker.can_approve?
  end

  def viewer?
    role_checker.can_view?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        viewer_policy_scope
      end
    end

    def viewer_policy_scope
      scope.where id: role_checker.viewer_project_ids
    end
  end
end