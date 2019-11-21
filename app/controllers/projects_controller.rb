class ProjectsController < ApplicationController
  def index
    @projects = Project.all
    jsonapi_render(@projects, allowed_filters)
  end

  private

  def allowed_filters
    [:slug]
  end
end
