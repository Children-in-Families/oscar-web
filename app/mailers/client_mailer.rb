class ClientMailer < ApplicationMailer
  def exited_notification(client, emails)
    @client         = client
    @manager_emails = emails.any? ? emails : User.admins.non_locked.pluck(:email)
    mail(to: @manager_emails, subject: 'Client has exited from NGO')
  end
end
