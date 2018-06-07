class Referral < ActiveRecord::Base
  has_paper_trail

  mount_uploader :consent_form, FileUploader

  belongs_to :client

  validates :client_name, :slug, :date_of_referral, :referred_from,
            :referred_to, :referral_reason, :referee_id, :name_of_referee,
            :referral_phone, :consent_form, presence: true

  validate :check_saved_referral_in_target_ngo, on: :update

  before_save :set_referred_from

  after_create :email_referrral_client
  after_save :make_a_copy_to_target_ngo

  scope :received, -> { where(referred_to: Organization.current.short_name) }
  scope :delivered, -> { where(referred_from: Organization.current.short_name) }
  scope :unsaved, -> { where(saved: false) }
  scope :saved, -> { where(saved: true) }
  scope :received_and_saved, -> { received.saved }
  scope :most_recents, -> { order(created_at: :desc) }

  def non_oscar_ngo?
    referred_to == 'external referral'
  end

  def referred_to_ngo
    referred_to = Organization.find_by(short_name: self.referred_to).try(:full_name)
    referred_to.present? ? referred_to : self.referred_to.titleize
  end

  def referred_from_ngo
    Organization.find_by(short_name: self.referred_from).try(:full_name)
  end

  private

  def check_saved_referral_in_target_ngo
    return if referred_to == 'external referral'
    org = Organization.current
    return if self.non_oscar_ngo?
    Organization.switch_to referred_to
    is_saved = Referral.find_by(slug: slug, date_of_referral: date_of_referral).try(:saved)
    Organization.switch_to org.short_name
    is_saved ? errors.add(:base, 'You cannot edit this referral because the target NGO already accepted the referral') : true
  end

  def set_referred_from
    current_org = Organization.current
    return if current_org.short_name == referred_to

    referred_from = Organization.find_by(full_name: self.referred_from).try(:short_name)
    self.referred_from = referred_from
  end

  def make_a_copy_to_target_ngo
    current_org = Organization.current
    return if current_org.short_name == referred_to || referred_to == "external referral"
    Organization.switch_to referred_to
    referral = Referral.find_or_initialize_by(slug: attributes['slug'], date_of_referral: attributes['date_of_referral'], saved: false)
    referral.attributes = attributes.except('id', 'client_id', 'created_at', 'updated_at', 'consent_form').merge({client_id: nil})
    referral.consent_form = consent_form
    referral.save
    Organization.switch_to current_org.short_name
  end

  def email_referrral_client
    current_org = Organization.current
    return if current_org.short_name == referred_to || referred_to == "external referral"
    EmailReferralClientWorker.perform_async(current_org.full_name, referred_to, slug)
  end
end
