class AbleScreeningMailer < ApplicationMailer
  default from: 'cifdonotreply@gmail.com'

  def notify_able_manager(client)
    @client = client
    mail(to: 'panhphanith.kh@gmail.com', subject: 'Client Join Able Program')
  end
end
