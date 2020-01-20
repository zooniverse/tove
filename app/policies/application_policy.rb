class ApplicationPolicy
  include UserRoles
  attr_reader :user, :records

  def initialize(user, records)
    @user = user
    @records = Array.wrap(records)
    raise Pundit::NotAuthorizedError, "must be logged in to Panoptes" unless logged_in?
  end

  def index?
    admin? || (logged_in? && viewer?)
  end

  def show?
    admin? || (logged_in? && viewer?)
  end

  def update?
    false
  end

  def admin?
    logged_in? && user.admin
  end

  def logged_in?
    !!user
  end

  class Scope
    include UserRoles
    attr_reader :user, :scope

    def initialize(user, scope)
      raise Pundit::NotAuthorizedError, "must be logged in to Panoptes" unless user
      @user = user
      @scope = scope
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
