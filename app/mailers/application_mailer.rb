class ApplicationMailer < ApplicationMailer
  default from:  ENV['SENDER_EMAIL']
  layout 'mailer'
end
