class ProjectsController < ApplicationController
  def index
    @projects = Project.all
    jsonapi_render(@projects, allowed_filters)
  end

  def show
    @project = Project.find(params[:id])
    render jsonapi: @project
  end

  private

  def allowed_filters
    [:slug]
  end
end
