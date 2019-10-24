Raven.configure do |config|
  config.dsn = Rails.application.credentials.sentry_dsn

  config.current_environment = Rails.application.credentials.sentry_env || Rails.env
  config.sanitize_fields = ["credentials"]
end
