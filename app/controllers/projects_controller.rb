class ProjectsController < ApplicationController
  def index
    @projects = policy_scope(Project)
    jsonapi_render(@projects, allowed_filters)
  end

  def show
    @project = policy_scope(Project).find(params[:id])
    render jsonapi: @project
  end

  private

  def allowed_filters
    [:slug]
  end
end
