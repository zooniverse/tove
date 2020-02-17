class ProjectsController < ApplicationController
  def index
    @projects = policy_scope(Project)
    jsonapi_render(@projects, allowed_filters)
  end

  def show
    @project = Project.find(params[:id])
    authorize @project
    render jsonapi: @project
  end

  def export
    @project = Project.find(params[:id])
    authorize @project

    data_storage = DataExports::DataStorage.new
    zip_file = data_storage.zip_project_files(@project) do |zip_file|
      send_export_file zip_file
    end
  end

  private

  def allowed_filters
    [:slug]
  end
end
