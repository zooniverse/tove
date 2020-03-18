module ErrorExtender
  extend ActiveSupport::Concern
  include JSONAPI::Errors

  included do
    rescue_from ActionController::BadRequest, with: :render_jsonapi_bad_request
    rescue_from Panoptes::Client::AuthenticationExpired, with: :render_jsonapi_token_expired
    rescue_from Pundit::NotAuthorizedError, with: :render_jsonapi_not_authorized
    rescue_from ActionDispatch::Http::Parameters::ParseError, with: :render_jsonapi_bad_request
    rescue_from TranscriptionsController::ValidationError, with: :render_jsonapi_bad_request
    rescue_from TranscriptionsController::LockedByAnotherUserError, with: :render_jsonapi_not_authorized
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
    super(exception)
  end

  def render_jsonapi_bad_request(exception)
    error = error_object(400, exception)
    render jsonapi_errors: [error], status: :bad_request
  end

  def render_jsonapi_token_expired(exception)
    error = error_object(401, exception)
    render jsonapi_errors: [error], status: :unauthorized
  end

  def render_jsonapi_not_authorized(exception)
    error = error_object(403, exception)
    render jsonapi_errors: [error], status: :forbidden
  end

  def error_object(status, exception)
    {
      status: status.to_s,
      title: Rack::Utils::HTTP_STATUS_CODES[status],
      detail: exception.to_s
    }
  end
end
