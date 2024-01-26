ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails_helper'
require 'shoulda/matchers'
require 'cancan/matchers'
require 'factory_girl'
require 'ffaker'
require 'capybara/rails'
require 'database_cleaner'
require 'rspec/active_model/mocks'
require 'capybara/poltergeist'
require 'mongoid-rspec'
require 'pundit/rspec'
require 'paper_trail/frameworks/rspec'
Dir[Rails.root.join('spec/supports/**/*.rb')].each { |f| require f }
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

Capybara.register_server :thin do |app, port, host|
  require 'rack/handler/thin'
  Rack::Handler::Thin.run(app, :Port => port, :Host => host)
end

Capybara.server = :thin
Capybara.always_include_port = true
Capybara.app_host = 'http://lvh.me'
Capybara.register_driver :poltergeist do |app|
  options = {
    js_errors: false,
    phantomjs_options: ['--debug=false', '--web-security=false', '--ignore-ssl-errors=yes', '--ssl-protocol=any', '--webdriver-logfile=/var/log/phantomjs.log'],
    timeout: 120,
    phantomjs: File.absolute_path(Phantomjs.path),
    url_whitelist: %w(http://app.lvh.me http://lvh.me http://localhost 127.0.0.1)
  }
  Capybara::Poltergeist::Driver.new(app, options)
end

Capybara.javascript_driver = :poltergeist

Capybara.server_port = 3001

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = [:should , :expect] }
  config.include Mongoid::Matchers
  config.include Warden::Test::Helpers
  config.include JsonSpec::Helpers
  config.include FeatureHelper
  config.include Select2
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.

  config.before(type: :feature) do
    allow_any_instance_of(Browser::Generic).to receive(:modern?) { true }
  end

  config.before(type: :request) do
    allow_any_instance_of(Browser::Generic).to receive(:modern?) { true }
  end

  config.include Requests::JsonHelpers, type: :request
  config.include DeviseTokenAuthHelpers, type: :request
  config.include ApplicationHelper

  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.before(:each, type: :feature) do
    default_url_options[:locale] = I18n.default_locale
    default_url_options[:country] = 'cambodia'
  end
  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  config.use_transactional_fixtures = false

  config.before(:suite) do
      # Clean all tables to start
      DatabaseCleaner.clean_with :truncation
      # Use transactions for tests
      # DatabaseCleaner.strategy = :transaction
      # Truncating doesn't drop schemas, ensure we're clean here, app *may not* exist
      Apartment::Tenant.drop('app') rescue nil
      Apartment::Tenant.drop('shared') rescue nil
      Apartment::Tenant.drop('shared_extensions') rescue nil
      # Create the default tenant for our tests
      Organization.create_and_build_tenant(full_name: 'Organization Testing', short_name: 'app')
      Organization.create_and_build_tenant(full_name: 'Shared Testing', short_name: 'shared')
      ActiveRecord::Base.connection.execute 'CREATE SCHEMA IF NOT EXISTS shared_extensions;'
      Apartment::Tenant.switch! 'app'
    end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
    # Apartment::Tenant.drop('app') rescue nil
    Organization.find_or_create_by(full_name: 'Organization Testing', short_name: 'app')
    Apartment::Tenant.switch! 'app'
    Setting.find_or_create_by(country_name: 'cambodia', max_case_note: 30, case_note_frequency: 'day', max_assessment: 6, age: 18, enable_default_assessment: true, enable_custom_assessment: true) do |setting|
      setting.family_default_columns = ["name_", "id_", "family_type_", "status_", "manage_"]
      setting.save
    end
    Apartment.configure do |config|
      config.default_tenant = 'app'
    end
  end

  config.before(:each, js: true) do
    # DatabaseCleaner.strategy = :truncation
    Capybara.default_max_wait_time = 10
    Capybara.always_include_port = true
    Capybara.app_host = "http://app.lvh.me"
  end

  config.after(:each) do
    # Apartment.configure do |config|
    #   config.default_tenant = 'public'
    # end
    if Rails.env.test? || Rails.env.cucumber?
      FileUtils.rm_rf(Dir["#{Rails.root}/spec/support/uploads"])
    end
    DatabaseCleaner.clean
    Apartment::Tenant.reset
  end

  # The settings below are suggested to provide a good initial experience
  # with RSpec, but feel free to customize to your heart's content.
  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://rspec.info/blog/2012/06/rspecs-new-expectation-syntax/
  #   - http://www.teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/#zero-monkey-patching-mode
  # config.disable_monkey_patching!

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
  config.include FactoryGirl::Syntax::Methods
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
