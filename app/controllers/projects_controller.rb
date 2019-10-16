class ProjectsController < ApplicationController
  include JSONAPI::Pagination
  include JSONAPI::Filtering

  def index
    @projects = Project.all
    jsonapi_filter(@projects, allowed_filters) do |filtered|
      jsonapi_paginate(filtered.result) do |paginated|
        render jsonapi: paginated
      end
    end
  end

  private

  def allowed_filters
    [:slug]
  end

end
