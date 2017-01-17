class AbleScreeningMailer < ApplicationMailer
  
  def notify_able_manager(client)
    @client = client
    mail(to: ENV['ABLE_MANAGER_EMAIL'], subject: 'Client Joint Able Program')
  end
end
