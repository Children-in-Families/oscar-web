class InternalReferral < ActiveRecord::Base
  extend Enumerize
  enumerize :referral_decision, in: ['meet_intake_criteria', 'not_meet_intake_criteria'], scope: true, predicates: true
  has_paper_trail

  mount_uploaders :attachments, ConsentFormUploader
  belongs_to :user, class_name: 'User', foreign_key: 'user_id'
  belongs_to :client, class_name: 'Client', foreign_key: 'client_id'

  has_many :internal_referral_program_streams, dependent: :destroy
  has_many :program_streams, through: :internal_referral_program_streams

  validates :referral_date, presence: true
  validates :user_id, presence: true
  validates :client_id, presence: true
  validates :program_stream_ids, presence: true
  validate :limit_referral_date

  after_save :sent_email_to_user

  def is_editable?
    setting = Setting.first
    return true if setting.try(:internal_referral_limit).zero?
    max_duration = setting.try(:internal_referral_limit).zero? ? 2 : setting.try(:internal_referral_limit)
    internal_referral_frequency = setting.try(:internal_referral_frequency)
    created_at >= max_duration.send(internal_referral_frequency).ago
  end

  private

  def sent_email_to_user
    unless client.exit_ngo?
      program_streams.each do |program_stream|
        program_stream.program_stream_users.each do |program_user|
          CaseWorkerClient.find_or_create_by(client_id: client.id, user_id: program_user.user_id)
        end
      end
    end
    InternalReferralWorker.perform_async(user.id, client.id, program_streams.ids)
  end

  def limit_referral_date
    if referral_date.present? && referral_date < (client.enter_ngos.first.accepted_date || client.initial_referral_date)
      errors.add(:referral_date, 'The referral date you have selected is invalid. Please select referral date before initial referral date and NGO accept date.')
    end
  end
end
