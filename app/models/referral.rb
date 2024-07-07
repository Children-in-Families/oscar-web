class Referral < ActiveRecord::Base
  include ClearanceOverdueConcern
  include ClientRetouch
  include ClearanceOverdueConcern

  has_paper_trail
  acts_as_paranoid

  mount_uploaders :consent_form, ConsentFormUploader

  LEVEL_OF_RISK = ['high', 'medium', 'low', 'no action'].freeze

  belongs_to :client
  has_and_belongs_to_many :services

  alias_attribute :new_date, :date_of_referral

  validates :client_name, :client_global_id, :date_of_referral, :referred_from,
            :referred_to, :referral_reason, :name_of_referee,
            :referral_phone, presence: true

  validates :consent_form, presence: true, if: :making_referral?
  validates :referee_id, presence: true, if: :slug_exist?

  validate :check_saved_referral_in_target_ngo, on: :update
  before_validation :set_referred_from
  validates :referral_status, presence: true, inclusion: { in: Client::CLIENT_STATUSES }
  validates :level_of_risk, presence: true, inclusion: { in: LEVEL_OF_RISK }
  validates :services, presence: true

  after_create :email_referrral_client, :inc_client_referral_count!
  after_save :make_a_copy_to_target_ngo, :create_referral_history

  scope :received, -> { where(referred_to: Organization.current.short_name) }
  scope :delivered, -> { where(referred_from: Organization.current.short_name) }
  scope :unsaved, -> { where(saved: false) }
  scope :saved, -> { where(saved: true) }
  scope :received_and_saved, -> { received.saved }
  scope :most_recents, -> { order(created_at: :desc) }
  scope :externals, -> { where(referred_to: 'external referral') }
  scope :get_external_systems, -> (external_system_name) { where('referrals.ngo_name = ?', external_system_name) }

  def received?
    referred_to == Organization.current.short_name
  end

  def delivered?
    referred_from == Organization.current.short_name
  end

  def non_oscar_ngo?
    referred_to =~ /external/i
  end

  def referred_to_ngo
    referred_to = Organization.find_by(short_name: self.referred_to).try(:full_name)
    referred_to.present? ? referred_to : self.referred_to.titleize
  end

  def referred_from_ngo
    Organization.find_by(short_name: self.referred_from).try(:full_name).presence || self.referred_from.capitalize
  end

  def making_referral?
    Organization.current.short_name == referred_from
  end

  def external_system
    ExternalSystem.find_by(name: ngo_name)
  end

  def self.get_referral_attribute(attribute)
    {
      date_of_referral: Date.today,
      referred_to: attribute[:organization_name],
      referral_reason: attribute[:reason_for_referral].presence || 'N/A',
      name_of_referee: attribute[:external_case_worker_name],
      referral_phone: attribute[:external_case_worker_mobile],
      referee_email: attribute[:external_case_worker_email],
      referee_id: attribute[:external_case_worker_id],
      client_name: "#{attribute[:given_name]} #{attribute[:family_name]}".squish,
      consent_form: [],
      ngo_name: 'MoSVY',
      client_gender: attribute[:gender],
      client_date_of_birth: attribute[:date_of_birth],
      client_global_id: attribute[:global_id].presence || GlobalIdentity.create(ulid: ULID.generate)&.ulid,
      external_id: attribute[:external_id],
      external_id_display: attribute[:external_id_display],
      mosvy_number: attribute[:mosvy_number],
      external_case_worker_name: attribute[:external_case_worker_name],
      external_case_worker_id: attribute[:external_case_worker_id],
      village_code: attribute[:location_current_village_code],
      level_of_risk: attribute[:level_of_risk],
      services: Service.where(name: attribute[:services]&.map { |service| service[:name] })
    }
  end

  def update_referral_status(value)
    update_column(:referral_status, value)
  end

  def inc_client_referral_count!
    client.update_columns(referral_count: client.referral_count + 1) if repeat?
  end

  def dec_client_referral_count!
    client.update_columns(referral_count: client.referral_count - 1) if repeat? && client.referral_count > 0
  end

  def client_by_slug
    @client_by_slug ||= Client.where('slug = ? OR archived_slug = ?', slug, slug).first
  end

  def repeat?
    client.present?
  end

  private

  def check_saved_referral_in_target_ngo
    current_org = Organization.current
    return if self.non_oscar_ngo? || current_org.short_name == referred_to

    Organization.switch_to referred_to
    is_saved = Referral.find_by(slug: slug, date_of_referral: date_of_referral).try(:saved)
    Organization.switch_to current_org.short_name
    is_saved ? errors.add(:base, 'You cannot edit this referral because the target NGO already accepted the referral') : true
  end

  def set_referred_from
    current_org = Organization.current
    return if current_org.short_name == referred_to

    referred_from = Organization.find_by(full_name: self.referred_from).try(:short_name) || self.referred_from
    self.referred_from = referred_from
  end

  def make_a_copy_to_target_ngo
    current_org = Organization.current
    return if non_oscar_ngo? || current_org.short_name == referred_to

    service_names = services.pluck(:name)
    referred_from_id = id
    Organization.switch_to referred_to
    referral = Referral.find_or_initialize_by(slug: attributes['slug'], saved: false)
    referral.attributes = attributes.except('id', 'client_id', 'created_at', 'updated_at', 'consent_form').merge({ client_id: nil })
    referral.consent_form = consent_form
    referral.services << Service.where(name: service_names) if service_names.present?
    referral.referred_from_uid = referred_from_id
    referral.save
    Organization.switch_to current_org.short_name
  end

  def email_referrral_client
    current_org = Organization.current
    return if self.non_oscar_ngo? || current_org.short_name == referred_to

    EmailReferralClientWorker.perform_async(current_org.full_name, referred_to, slug)
  end

  def create_referral_history
    ReferralHistory.initial(self)
  end

  def slug_exist?
    slug.present?
  end
end
