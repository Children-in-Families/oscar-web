if Rails.env.staging?
  interceptor = MailInterceptor::Interceptor.new({ forward_emails_to: ENV['FORWARD_EMAIL'] })
  ActionMailer::Base.register_interceptor(interceptor)
end