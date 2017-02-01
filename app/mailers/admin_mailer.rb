class AdminMailer < ActionMailer::Base
  default from: 'info@cambodianfamilies.com'

  def remind_of_client(clients, options = {})
    @clients = clients
    @admin   = options[:admin]
    @day     = options[:day]

    mail(to: @admin.email, subject: 'Reminder there is client about to exit emergency case program')
  end
end
