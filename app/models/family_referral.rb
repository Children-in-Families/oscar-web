class FamilyReferral < ActiveRecord::Base
  include ClearanceOverdueConcern

  has_paper_trail

  mount_uploaders :consent_form, ConsentFormUploader

  belongs_to :family

  alias_attribute :new_date, :date_of_referral

  validates :name_of_family, :date_of_referral, :referred_from,
            :referred_to, :referral_reason, :name_of_referee,
            :referral_phone, presence: true

  validates :consent_form, presence: true, if: :making_referral?
  validates :referee_id, presence: true, if: :slug_exist?

  validate :check_saved_referral_in_target_ngo, on: :update
  before_validation :set_referred_from

  after_create :email_referrral_family
  after_save :make_a_copy_to_target_ngo

  scope :received, -> { where(referred_to: Organization.current.short_name) }
  scope :delivered, -> { where(referred_from: Organization.current.short_name) }
  scope :unsaved, -> { where(saved: false) }
  scope :saved, -> { where(saved: true) }
  scope :received_and_saved, -> { received.saved }
  scope :most_recents, -> { order(created_at: :desc) }
  scope :externals, -> { where(referred_to: 'external referral') }
  scope :get_external_systems, -> (external_system_name) { where('referrals.ngo_name = ?', external_system_name) }

  def non_oscar_ngo?
    referred_to == 'external referral' || referred_to == 'MoSVY External System'
  end

  def referred_to_ngo
    referred_to = Organization.find_by(short_name: self.referred_to).try(:full_name)
    referred_to.present? ? referred_to : self.referred_to.titleize
  end

  def referred_from_ngo
    Organization.find_by(short_name: self.referred_from).try(:full_name) || self.referred_from
  end

  def making_referral?
    Organization.current.short_name == referred_from
  end

  def self.get_referral_attribute(attribute)
    {
      date_of_referral: Date.today,
      referred_to: attribute[:organization_name],
      referral_reason: attribute[:reason_for_referral].presence || 'N/A',
      name_of_referee: attribute[:external_case_worker_name],
      referral_phone: attribute[:external_case_worker_mobile],
      referee_id: attribute[:external_case_worker_id],
      consent_form: [],
      ngo_name: 'MoSVY'
    }
  end

  private

  def check_saved_referral_in_target_ngo
    current_org = Organization.current
    return if non_oscar_ngo? || current_org.short_name == referred_to

    Organization.switch_to referred_to
    is_saved = FamilyReferral.find_by(slug: slug, date_of_referral: date_of_referral).try(:saved)
    Organization.switch_to current_org.short_name
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
    return if self.non_oscar_ngo? || current_org.short_name == referred_to

    referred_from_id = id
    Organization.switch_to referred_to
    referral = FamilyReferral.find_or_initialize_by(slug: attributes['slug'], saved: false)
    referral.attributes = attributes.except('id', 'created_at', 'updated_at', 'consent_form', 'family_id').merge({ family_id: nil })
    referral.consent_form = consent_form
    referral.referred_from_uid = referred_from_id
    referral.save
    Organization.switch_to current_org.short_name
  end

  def email_referrral_family
    current_org = Organization.current
    return if self.non_oscar_ngo? || current_org.short_name == referred_to
    EmailFamilyReferralWorker.perform_async(current_org.full_name, referred_to, slug)
  end

  def slug_exist?
    slug.present?
  end
end
