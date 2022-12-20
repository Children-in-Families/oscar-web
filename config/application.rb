require_relative 'boot'

require 'rails/all'
require 'apartment/elevators/subdomain'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
module CifWeb
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading

    # the framework and any gems in your application.
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Bangkok'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    #config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :km, :my, :en]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

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
          :expose  => ['access-token', 'expiry', 'token-type', 'uid', 'client'],
          :methods => [:get, :post, :options, :delete, :put]
      end
    end

    # custom error page
    config.exceptions_app = self.routes

    # Mongod db database name
    config.history_database_name = Rails.env.test? ? ENV['HISTORY_DATABASE_NAME_TEST'] : ENV['HISTORY_DATABASE_NAME']
  end
end
