class Referral < ActiveRecord::Base
  has_paper_trail

  mount_uploaders :consent_forms, FileUploader

  belongs_to :client

  after_create :email_referrral_client
  after_save :make_a_copy_to_target_ngo

  scope :received, -> { where(referred_to: Organization.current.short_name) }
  scope :unsaved, -> { where(saved: false) }

  private

  def make_a_copy_to_target_ngo
    current_org = Organization.current
    return if current_org.short_name == referred_to || referred_to == "external referral"
    Organization.switch_to referred_to
    referral = Referral.find_or_initialize_by(slug: attributes['slug'])
    referral.attributes = attributes.except('id', 'client_id', 'created_at', 'updated_at', 'consent_forms').merge({client_id: nil})
    referral.consent_forms = consent_forms
    referral.save
    Organization.switch_to current_org.short_name
  end

  def email_referrral_client
    current_org = Organization.current
    return if current_org.short_name == referred_to || referred_to == "external referral"
    EmailReferralClientWorker.perform_async(current_org.full_name, referred_to, slug)
  end
end
