module ErrorExtender
  extend ActiveSupport::Concern
  include JSONAPI::Errors

  included do
    rescue_from ActionController::BadRequest, with: :render_jsonapi_bad_request
    rescue_from ActiveModel::UnknownAttributeError, with: :render_jsonapi_unknown_attribute
    rescue_from StandardError, with: :report_to_sentry
  end

  def report_to_sentry(exception)
    if current_user
      Raven.user_context(
        id: current_user.id,
        username: current_user.login,
        roles: current_user.roles,

      )
    end

    Raven.capture_exception(exception)
    render_jsonapi_internal_server_error(exception)
  end

  def render_jsonapi_bad_request(exception)
    error = { status: '400', title: Rack::Utils::HTTP_STATUS_CODES[400] }
    render jsonapi_errors: [error], status: :bad_request
  end

  def render_jsonapi_unknown_attribute(exception)
    error = {
      status: '422',
      title: Rack::Utils::HTTP_STATUS_CODES[422],
      detail: exception.to_param
    }

    render jsonapi_errors: [error], status: :unprocessable_entity
  end
end
