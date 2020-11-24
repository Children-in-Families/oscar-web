# config/initializers/sentry.rb
## TODO: Some mechanism to get the current git revision into the Rails app,
##       that depends on your deploy process.
##       e.g. ENV['CI_BUILD_REF'],
##            or `git rev-parse`.strip if you are deploying with the whole .git
SENTRY_RELEASE = if File.exist?("GIT_REVISION")
                   File.read("GIT_REVISION")
                 else
                   ""
                 end
Raven.configure do |config|
  if Rails.env.production? || Rails.env.staging? || Rails.env.development?
    config.dsn = 'https://19e7decf52684417b2414ba7fd360e45@o480860.ingest.sentry.io/5528553'
    # env: config.dsn = ENV['...']
    # secrets: config.dsn = Rails.application.secrets.sentry_dsn
  end
  # which envs to report, could be staging to
  config.environments = %w[production staging development]
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
