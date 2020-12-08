module TestingSupport
  module SubdomainHelpers
    def within_subdomain
      before {
        if Capybara.current_driver != :rack_test
          Capybara.app_host = "http://app.yourappname-test.com"
        else
          Capybara.app_host = "http://app.example.com"
        end
      }

      after { Capybara.app_host = "http://www.example.com" }
      yield
    end

    RSpec.configure do |config|
    config.extend SubdomainHelpers, :type => :feature
    end
  end
end
