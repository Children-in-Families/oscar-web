class CaseNoteOverdueMailer < ApplicationMailer
  def overdue_case_notes_notify(client_ids, user, short_name)
    clients = Client.where(id: client_ids)
    @clients         = clients
    @user = user
    @short_name = short_name
    mail(to: user.email, subject: 'Clients have overdue for case note')
  end
end
