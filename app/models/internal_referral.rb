class InternalReferral < ActiveRecord::Base
  mount_uploaders :attachments, ConsentFormUploader
  belongs_to :user, class_name: "User", foreign_key: "user_id"
  belongs_to :client, class_name: "Client", foreign_key: "client_id"

  has_many :internal_referral_program_streams, dependent: :destroy
  has_many :program_streams, through: :internal_referral_program_streams

  validates :referral_date, presence: true
  validates :user_id, presence: true
  validates :client_id, presence: true
  validates :program_stream_ids, presence: true

  after_save :sent_email_to_user

  private

  def sent_email_to_user
    program_streams.each do |program_stream|
      program_stream.program_stream_users.each do |program_user|
        CaseWorkerClient.find_or_create_by(client_id: client.id, user_id: program_user.id)
      end
    end
    InternalReferralWorker.perform_async(user.id, client.id, program_streams.ids)
  end
end
