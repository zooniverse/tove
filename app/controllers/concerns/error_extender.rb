module ErrorExtender
  extend ActiveSupport::Concern

  included do
    include JSONAPI::Errors

    # we really only need to add this for the sake of the test environment, since jsonapi.rb omits it for env.test
    # use `unshift` to place handler at start of handler array, so that it doesn't override prev handlers
    rescue_handlers.unshift([StandardError.name, :render_jsonapi_internal_server_error])

    rescue_from ActionController::BadRequest, with: :render_jsonapi_bad_request
    rescue_from Panoptes::Client::AuthenticationExpired, with: :render_jsonapi_token_expired
    rescue_from Pundit::NotAuthorizedError, with: :render_jsonapi_not_authorized
    rescue_from ActionDispatch::Http::Parameters::ParseError, with: :render_jsonapi_bad_request
    rescue_from TranscriptionsController::ValidationError, with: :render_jsonapi_bad_request
    rescue_from TranscriptionsController::LockedByAnotherUserError, with: :render_jsonapi_not_authorized
    rescue_from TranscriptionsController::NoExportableTranscriptionsError, with: :render_jsonapi_not_found
    rescue_from DataExports::DataStorage::NoStoredFilesFoundError, with: :render_jsonapi_not_found
    rescue_from ActiveRecord::StaleObjectError, with: :render_jsonapi_conflict

    # override JSONAPI::Errors method to include exception message
    def render_jsonapi_not_found(exception)
      error = { status: '404', title: Rack::Utils::HTTP_STATUS_CODES[404], detail: exception.to_s }
      render jsonapi_errors: [error], status: :not_found
    end

    # Overriding this JSONAPI::Errors method to add Sentry reporting
    def render_jsonapi_internal_server_error(exception)
      report_to_sentry(exception)
      super(exception)
    end
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

  def render_jsonapi_conflict(exception)
    error = error_object(409, exception)
    render jsonapi_errors: [error], status: :conflict
  end

  def error_object(status, exception)
    {
      status: status.to_s,
      title: Rack::Utils::HTTP_STATUS_CODES[status],
      detail: exception.to_s
    }
  end
end
