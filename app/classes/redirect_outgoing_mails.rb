class RedirectOutgoingMails
  class << self

    def delivering_email(mail)
      return if mail.subject == 'Reset password instructions'
      mail.to = ENV['FORWARD_EMAIL']
      mail.cc = ENV['FORWARD_EMAIL']
      mail.bcc = ENV['FORWARD_EMAIL']
    end
  end
end
