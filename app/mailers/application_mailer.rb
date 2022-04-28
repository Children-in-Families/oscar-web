class ApplicationMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default from: ENV['SENDER_EMAIL'], bcc: [ENV['DEV_EMAIL'], ENV['DEV2_EMAIL']]
  layout 'mailer'
end
