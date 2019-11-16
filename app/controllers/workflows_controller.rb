class WorkflowsController < ApplicationController
  include JSONAPI::Deserialization

  def index
    @workflows = Workflow.all
    jsonapi_render(@workflows, allowed_filters)
  end

  def show
    @workflow = Workflow.find(params[:id])
    render jsonapi: @workflow
  end

  private

  def allowed_filters
    [:display_name, :project_id]
  end
end
