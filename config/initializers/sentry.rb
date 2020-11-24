SENTRY_RELEASE = if File.exist?(Rails.root.join('REVISION'))
                   File.read(Rails.root.join('REVISION'))
                 else
                   ""
                 end
Raven.configure do |config|
  if Rails.env.production? || Rails.env.staging?
    config.dsn = ENV['SENTRY_DSN']
    # env: config.dsn = ENV['...']
    # secrets: config.dsn = Rails.application.secrets.sentry_dsn
  end
  # which envs to report, could be staging to
  config.environments = %w[production staging]
  config.release = SENTRY_RELEASE
  # Do this to send POST data, sentry DOES NOT send POST params by default
  config.processors -= [Raven::Processor::PostData]
  # Do this to send cookies by default, otherwise session/cookies info will not be send
  config.processors -= [Raven::Processor::Cookies]
  # What fields do you want to sanitize?
  config.sanitize_fields = ["first_name", "last_name", "email", "telephone", "phone", "password", "password_confirmation"]
  config.excluded_exceptions =
    Raven::Configuration::IGNORE_DEFAULT + [
      'ActiveRecord::RecordNotFound',
      'ActionController::RoutingError',
      'ActionController::InvalidAuthenticityToken',
      'CGI::Session::CookieStore::TamperedWithCookie',
      'ActionController::UnknownAction',
      'AbstractController::ActionNotFound',
      'Mongoid::Errors::DocumentNotFound'
    ].freeze
end
