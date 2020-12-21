require_relative 'boot'

require 'rails'

# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'
require 'apartment/elevators/subdomain'
# Require the gems listed in Gemfile, including any gems

# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CifWeb
  class Application < Rails::Application
    config.load_defaults 5.2

    config.middleware.use Apartment::Elevators::Subdomain
    config.middleware.insert_before Warden::Manager, Apartment::Elevators::Subdomain
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
  end
end
