class RoleChecker
  attr_reader :user, :records

  EDITOR_ROLES = %w(owner collaborator expert scientist moderator)
  APPROVER_ROLES = %w(owner collaborator)
  VIEWER_ROLES = %w(owner collaborator expert scientist tester)

  def initialize(user, records)
    @user = user
    @records = records
    @viewer_project_ids = viewer_project_ids
  end

  def can_edit?
    ids = user_role_ids(user.roles, EDITOR_ROLES)
    check_roles(ids, records)
  end

  def can_approve?
    ids = user_role_ids(user.roles, APPROVER_ROLES)
    check_roles(ids, records)
  end

  def can_view?
    ids = user_role_ids(user.roles, VIEWER_ROLES)
    check_roles(ids, records)
  end

  def viewer_project_ids
    user_role_ids(user.roles, VIEWER_ROLES)
  end

  def user_role_ids(user_roles, allowed_roles)
    allowed_role_ids = []
    user_roles.each do |id, roles|
      if (roles & allowed_roles).any?
        allowed_role_ids << id
      end
    end
    allowed_role_ids
  end

  def check_roles(project_ids, records)
    records.all? do |record|
      project_ids.include? record.id.to_s
    end
  end
end
