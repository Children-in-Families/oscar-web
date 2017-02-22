class ManagerMailer < ActionMailer::Base
  default from: 'info@cambodianfamilies.com'

  def remind_of_client(clients, options = {})
    @clients = clients
    @manager = options[:manager]
    @day     = options[:day]

    mail(to: @manager, subject: 'Reminder there is client about to exit emergency case program')
  end
end
