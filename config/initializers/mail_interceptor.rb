if Rails.env.staging? || Rails.env.demo?
  ActionMailer::Base.register_interceptor(RedirectOutgoingMails)
end
