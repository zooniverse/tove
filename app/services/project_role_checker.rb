class ProjectRoleChecker
  attr_reader :user, :records, :viewer_project_ids, :editor_project_ids

  EDITOR_ROLES = %w(owner collaborator expert scientist moderator)
  APPROVER_ROLES = %w(owner collaborator)
  VIEWER_ROLES = %w(owner collaborator expert scientist moderator tester)

  def initialize(user, records)
    @user = user
    @records = records
    @viewer_project_ids = get_viewer_project_ids
    @editor_project_ids = get_editor_project_ids
  end

  def can_edit?
    ids = user_project_ids(user.roles, EDITOR_ROLES)
    check_roles(ids, records)
  end

  def can_approve?
    ids = user_project_ids(user.roles, APPROVER_ROLES)
    check_roles(ids, records)
  end

  def can_view?
    ids = user_project_ids(user.roles, VIEWER_ROLES)
    check_roles(ids, records)
  end

  def get_viewer_project_ids
    user_project_ids(user.roles, VIEWER_ROLES)
  end

  def get_editor_project_ids
    user_project_ids(user.roles, EDITOR_ROLES)
  end

  private

  def user_project_ids(user_roles, allowed_roles)
    allowed_role_ids = []
    user_roles.each do |id, roles|
      if (roles & allowed_roles).any?
        allowed_role_ids << id
      end
    end
    allowed_role_ids
  end

  def check_roles(project_ids, records)
    return false if records.empty?
    records.all? do |record|
      project_ids.include? record.id.to_s
    end
  end
end
