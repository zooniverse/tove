class WorkflowsController < ApplicationController
  def index
    @workflows = policy_scope(Workflow)
    jsonapi_render(@workflows, allowed_filters)
  end

  def show
    @workflow = Workflow.find(params[:id])
    authorize @workflow
    render jsonapi: @workflow
  end

  def export
    @workflow = Workflow.find(params[:id])
    authorize @workflow

    data_storage = DataExports::DataStorage.new
    zip_file = data_storage.zip_workflow_files(@workflow) do |zip_file|
      send_export_file zip_file
    end
  end

  private

  def allowed_filters
    [:display_name, :project_id]
  end
end
