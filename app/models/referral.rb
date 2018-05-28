class Referral < ActiveRecord::Base
  has_paper_trail

  mount_uploader :consent_form, FileUploader

  belongs_to :client

  after_create :create_referral

  scope :received, -> { where(referred_to: Organization.current.short_name) }
  scope :unsaved, -> { where(saved: false) }
  private

  def create_referral
    current_org = Organization.current
    return if current_org.short_name == referred_to
    Organization.switch_to referred_to
    Referral.find_or_create_by(attributes.except('id', 'client_id', 'created_at', 'updated_at').merge({client_id: nil}))
    Organization.switch_to current_org.short_name
  end
end
