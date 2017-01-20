class AbleScreeningMailer < ApplicationMailer
  default from: 'cifdonotreply@gmail.com'

  def notify_able_manager(client)
    @client = client
    mail(to: ENV['ABLE_MANAGER_EMAIL'], subject: 'Client Joint Able Program')
  end
end
