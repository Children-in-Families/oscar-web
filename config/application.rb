require File.expand_path('../boot', __FILE__)

require 'rails/all'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CifWeb
  class Application < Rails::Application
    config.api_only = true
    config.middleware.use 'Apartment::Elevators::Subdomain'
    config.middleware.insert_before 'Warden::Manager', 'Apartment::Elevators::Subdomain'
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Bangkok'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    #config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = true
    config.i18n.available_locales = [:en, :km, :my, :th, :id, :ne]
    config.i18n.enforce_available_locales = true
    # Custom I18n fallbacks
    config.after_initialize do
      Globalize.fallbacks = { id: :en, my: :en, ne: :en, th: :en }
    end

    # config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    # Autoload path
    config.enable_dependency_loading = true
    config.autoload_paths << "#{Rails.root}/lib"
    config.autoload_paths << Rails.root.join('app/classes/**/*')

    # Override rails template engine: erb to haml
    config.generators do |g|
      g.template_engine :haml
    end

    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource '*',
          :headers => :any,
          :expose => ['access-token', 'expiry', 'token-type', 'uid', 'client'],
          :methods => [:get, :post, :options, :delete, :put]
      end
    end

    # Do not allow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # custom error page
    config.exceptions_app = self.routes

    # Mongod db database name
    config.history_database_name = Rails.env.test? ? ENV['HISTORY_DATABASE_NAME_TEST'] : ENV['HISTORY_DATABASE_NAME']
  end
end
