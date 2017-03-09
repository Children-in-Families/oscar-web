class AdminMailer < ActionMailer::Base
  default from: 'info@cambodianfamilies.com'

  def remind_of_client(clients, options = {})
    @clients = clients
    @admin   = options[:admin]
    @day     = options[:day]
    mail(to: @admin, subject: 'Reminder [Clients Are About To Exit Emergency Care Program')
  end
end
