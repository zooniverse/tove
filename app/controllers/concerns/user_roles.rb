module UserRoles
  extend ActiveSupport::Concern

  def editor_project_ids
    return [] unless user
    @editor_project_ids ||= user.roles.select do |id, roles|
      (roles & %w(owner collaborator expert scientist)).any?
    end.keys
  end

  def approver_project_ids
    return [] unless user
    @approver_project_ids ||= user.roles.select do |id, roles|
      (roles & %w(owner collaborator)).any?
    end.keys
  end

  def viewer_project_ids
    return [] unless user
    @viewer_project_ids ||= user.roles.select do |id, roles|
      (roles & %w(tester)).any?
    end.keys
  end
end
