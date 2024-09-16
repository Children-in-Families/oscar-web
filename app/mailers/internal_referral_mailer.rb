class InternalReferralMailer < ApplicationMailer

  def send_to(user_id, user_name, user_email, client_id, program_stream_id)
    Apartment::Tenant.switch 'ratanak'
    @user = User.find(user_id)
    @client = Client.find(client_id)
    @program_stream = ProgramStream.find(program_stream_id)
    @user_name = user_name
    mail(to: user_email, subject: 'New internal referral') if user_email && @client && @program_stream
  end
end
