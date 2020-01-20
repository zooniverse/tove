class WorkflowsController < ApplicationController
  def index
    @workflows = policy_scope(Workflow)
    jsonapi_render(@workflows, allowed_filters)
  end

  def show
    @workflow = policy_scope(Workflow).find(params[:id])
    render jsonapi: @workflow
  end

  private

  def allowed_filters
    [:display_name, :project_id]
  end
end
