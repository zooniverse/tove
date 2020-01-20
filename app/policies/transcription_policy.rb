class TranscriptionPolicy < ApplicationPolicy
  delegate :editor?, :approver?, :viewer?, to: :project_policy

  def update?
    admin? || (logged_in? && editor?)
  end

  def project_policy
    ProjectPolicy.new(user, projects)
  end

  def projects
    # Project.where(id: records.collect(&:workflow).pluck(:project_id).uniq)
    records.collect(&:workflow).collect(&:project)
  end

  class Scope < Scope
    def resolve
      viewer_policy_scope
    end

    def viewer_policy_scope
      if user.admin?
        scope.all
      elsif user
        scope.joins(:workflow).where(workflows: { project_id: viewer_project_ids } )
      end
    end
  end
end