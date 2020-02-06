class ApplicationPolicy
  attr_reader :user, :records, :role_checker

  def initialize(user, records)
    @user = user
    @records = Array.wrap(records)
    raise Pundit::NotAuthorizedError, "must be logged in to Panoptes" unless logged_in?
    @role_checker = ProjectRoleChecker.new(user, @records)
  end

  def index?
    admin? || (logged_in? && viewer?)
  end

  def show?
    admin? || (logged_in? && viewer?)
  end

  def export?
    admin? || (logged_in? && editor?)
  end

  def admin?
    logged_in? && user.admin
  end

  def logged_in?
    !!user
  end

  class Scope
    attr_reader :user, :scope, :role_checker

    def initialize(user, scope)
      raise Pundit::NotAuthorizedError, "must be logged in to Panoptes" unless user
      @user = user
      @scope = scope
      @role_checker = ProjectRoleChecker.new(user, scope)
    end
  end
end
