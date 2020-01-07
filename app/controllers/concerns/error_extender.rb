module ErrorExtender
  extend ActiveSupport::Concern
  include JSONAPI::Errors

  included do
    rescue_from ActionController::BadRequest, with: :render_jsonapi_bad_request
    rescue_from ActiveModel::UnknownAttributeError, with: :render_jsonapi_unknown_attribute
    rescue_from Panoptes::Client::AuthenticationExpired, with: :render_jsonapi_token_expired
  end

  def report_to_sentry(exception)
    if current_user
      Raven.user_context(
        id: current_user.id,
        username: current_user.login,
        roles: current_user.roles
      )
    end
    Raven.capture_exception(exception)
  end

  # Overriding this JSONAPI::Errors method to add Sentry reporting
  def render_jsonapi_internal_server_error(exception)
    report_to_sentry(exception)
    error = { status: '500', title: Rack::Utils::HTTP_STATUS_CODES[500] }
    render jsonapi_errors: [error], status: :internal_server_error
  end

  def render_jsonapi_bad_request(exception)
    error = { status: '400', title: Rack::Utils::HTTP_STATUS_CODES[400] }
    render jsonapi_errors: [error], status: :bad_request
  end

  def render_jsonapi_token_expired(exception)
    error = { status: '401', title: Rack::Utils::HTTP_STATUS_CODES[401] }
    render jsonapi_errors: [error], status: :unauthorized
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
