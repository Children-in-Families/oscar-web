Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false
  # config.force_ssl = true

  # Show full error reports and disable caching.
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.cache_store = :memory_store

  # Don't care if the mailer can't send.
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  # config.action_mailer.delivery_method = :smtp

  # config.action_mailer.smtp_settings = {
  #   address:               'email-smtp.us-east-1.amazonaws.com',
  #   authentication:        :login,
  #   user_name:             ENV['AWS_SES_USER_NAME'],
  #   password:              ENV['AWS_SES_PASSWORD'],
  #   enable_starttls_auto:  true,
  #   port:                  465,
  #   openssl_verify_mode:   OpenSSL::SSL::VERIFY_NONE,
  #   ssl:                   true,
  #   tls:                   true
  # }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.action_mailer.default_url_options = { host: 'lvh.me', port: 3000 }
  config.action_mailer.delivery_method = :letter_opener_web

  config.after_initialize do
    Bullet.enable = true
    # Bullet.alert = true
    # Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
    # Bullet.stacktrace_includes = true
    # Bullet.raise = true
  end

  LetterOpenerWeb.configure do |config|
    config.letters_location = Rails.root.join('tmp', 'letter_opener')
  end
  # config.asset_host = 'http://localhost:3000'
end
