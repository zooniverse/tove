module ErrorExtender
  extend ActiveSupport::Concern

  included do
    include JSONAPI::Errors

    # call report_to_sentry before render_jsonapi_internal_server_error
    method = instance_method(:render_jsonapi_internal_server_error)
    define_method(:render_jsonapi_internal_server_error) do |*args, &block|
      report_to_sentry(*args)
      method.bind(self).(*args, &block)
    end

    if ::Rails.env.test?
      rescue_handlers.unshift([StandardError.name, :render_jsonapi_internal_server_error])
    end

    rescue_from ActionController::BadRequest, with: :render_jsonapi_bad_request
    rescue_from Panoptes::Client::AuthenticationExpired, with: :render_jsonapi_token_expired
    rescue_from Pundit::NotAuthorizedError, with: :render_jsonapi_not_authorized
    rescue_from ActionDispatch::Http::Parameters::ParseError, with: :render_jsonapi_bad_request
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
    error = { status: '400', title: Rack::Utils::HTTP_STATUS_CODES[400] }
    render jsonapi_errors: [error], status: :bad_request
  end

  def render_jsonapi_token_expired(exception)
    error = { status: '401', title: Rack::Utils::HTTP_STATUS_CODES[401] }
    render jsonapi_errors: [error], status: :unauthorized
  end

  def render_jsonapi_not_authorized
    error = { status: '403', title: Rack::Utils::HTTP_STATUS_CODES[403] }
    render jsonapi_errors: [error], status: :forbidden
  end
end
