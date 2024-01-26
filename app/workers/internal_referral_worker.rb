class InternalReferralWorker
  include Sidekiq::Worker

  def perform(*args)
    Apartment::Tenant.switch 'ratanak'
    user_id = args[0]
    client_id = args[1]
    program_stream_ids = args[2]
    program_streams = ProgramStream.where(id: program_stream_ids)
    program_streams.each do |program_stream|
      users = program_stream.internal_referral_users.distinct
      users.each do |user|
        next if user.email.blank?

        user_name = user.name
        user_email = user.email
        InternalReferralMailer.send_to(user_id, user_name, user_email, client_id, program_stream.id).deliver_now
      end
    end
  end
end
