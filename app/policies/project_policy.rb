class ProjectPolicy < ApplicationPolicy
  def editor?
    return false if records.empty?
    records.compact.all? do |record|
      editor_project_ids.include? record.id.to_s
    end
  end

  def approver?
    return false if records.empty?
    records.compact.all? do |record|
      approver_project_ids.include? record.id.to_s
    end
  end

  def viewer?
    return false if records.empty?
    records.compact.all? do |record|
      viewer_project_ids.include? record.id.to_s
    end
  end

  class Scope < Scope
    def resolve
      if user && user.admin?
        scope.all
      else
        viewer_policy_scope
      end
    end

    def viewer_policy_scope
      if user
        scope.where id: viewer_project_ids
      else
        scope.none
      end
    end
  end
end