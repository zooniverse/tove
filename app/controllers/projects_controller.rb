class ProjectsController < ApplicationController
  def index
    @projects = Project.all
    jsonapi_render(@projects, allowed_filters)
  end

  private

  def allowed_filters
    [:slug]
  end

  def jsonapi_meta(resources)
    pagination = jsonapi_pagination_meta(resources)
    { pagination: pagination } if pagination.present?
  end
end
