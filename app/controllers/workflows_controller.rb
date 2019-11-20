class WorkflowsController < ApplicationController
  def index
    @workflows = Workflow.all
    jsonapi_render(@workflows, allowed_filters)
  end

  private

  def allowed_filters
    [:display_name, :project_id]
  end

  def jsonapi_meta(resources)
    pagination = jsonapi_pagination_meta(resources)
    { pagination: pagination } if pagination.present?
  end
end
