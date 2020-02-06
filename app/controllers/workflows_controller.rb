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
    export_resource(@workflow)
  end

  private

  def allowed_filters
    [:display_name, :project_id]
  end
end
