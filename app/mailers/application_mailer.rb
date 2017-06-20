class ApplicationMailer < ActionMailer::Base
  default from: ENV['SENDER_EMAIL']
  layout 'mailer'
end
