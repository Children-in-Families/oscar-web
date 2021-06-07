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
    InternalReferralWorker.perform_async(user.id, client.id, program_streams.ids)
  end
end
