class ClientMailer < ApplicationMailer

  def exited_notification(emails)
    @manager_emails = emails
    mail(to: @manager_emails, subject: 'Client has exited from NGO')
  end
end
