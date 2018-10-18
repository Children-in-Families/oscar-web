class ApplicationMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default from: ENV['SENDER_EMAIL']
  layout 'mailer'
end
