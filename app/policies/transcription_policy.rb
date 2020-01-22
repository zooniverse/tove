class TranscriptionPolicy < ApplicationPolicy
  delegate :editor?, :approver?, :viewer?, to: :project_policy

  def update?
    has_update_rights?
  end

  def approve?
    if has_update_rights?
      approver? || admin?
    else
      false
    end
  end

  def has_update_rights?
    admin? || (logged_in? && editor?)
  end

  def project_policy
    ProjectPolicy.new(user, Project.where(id: records.collect(&:workflow).pluck(:project_id).uniq))
  end

  class Scope < Scope
    def resolve
      viewer_policy_scope
    end

    def viewer_policy_scope
      if user.admin?
        scope.all
      elsif user
        scope.joins(:workflow).where(workflows: { project_id: role_checker.viewer_project_ids } )
      end
    end
  end
end