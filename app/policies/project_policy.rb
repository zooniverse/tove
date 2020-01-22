class ProjectPolicy < ApplicationPolicy
  def editor?
    return false if records.empty?
    role_checker.can_edit?
  end

  def approver?
    return false if records.empty?
    role_checker.can_approve?
  end

  def viewer?
    return false if records.empty?
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