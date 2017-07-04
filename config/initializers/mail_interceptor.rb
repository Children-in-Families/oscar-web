if Rails.env.staging?
  ActionMailer::Base.register_interceptor(RedirectOutgoingMails)
end
