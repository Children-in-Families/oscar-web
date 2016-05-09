class Client < ActiveRecord::Base
  extend FriendlyId
  attr_accessor :assessment_id

  friendly_id :slug, use: :slugged

  CLIENT_STATUSES = ['Referred', 'Active EC', 'Active KC', 'Active FC', 'Independent - Monitored', 'Exited - Deseased', 'Exited - Age Out', 'Exited Independent', 'Exited Adopted', 'Exited Other'].freeze

  EXIT_STATUSES   = CLIENT_STATUSES.select { |status| status if status.include?('Exited') }

  belongs_to :referral_source,  counter_cache: true
  belongs_to :province,         counter_cache: true
  belongs_to :user,             counter_cache: true
  belongs_to :received_by,      class_name: 'User',     foreign_key: 'received_by_id',    counter_cache: true
  belongs_to :followed_up_by,   class_name: 'User',     foreign_key: 'followed_up_by_id', counter_cache: true
  belongs_to :birth_province,   class_name: 'Province', foreign_key: 'birth_province_id', counter_cache: true

  has_many :cases,       dependent: :destroy
  has_many :tasks,       dependent: :destroy
  has_many :case_notes,  dependent: :destroy
  has_many :assessments, dependent: :destroy
  has_many :government_reports, dependent: :destroy

  accepts_nested_attributes_for     :tasks

  has_and_belongs_to_many :agencies
  has_and_belongs_to_many :quantitative_cases

  validates :rejected_note, presence: true, on: :update, if: :reject?

  before_update :reset_user_to_tasks
  after_create  :set_slug_as_alias

  scope :first_name_like,      -> (value) { where('LOWER(clients.first_name) LIKE ?', "%#{value.downcase}%") }

  scope :start_with_code,      -> (value) { where('code LIKE ?', "#{value}%") }

  scope :status_like,          ->         { CLIENT_STATUSES }

  scope :current_address_like, -> (value) { where('LOWER(clients.current_address) LIKE ?', "%#{value.downcase}%") }

  scope :school_name_like,     -> (value) { where('LOWER(clients.school_name) LIKE ?', "%#{value.downcase}%") }

  scope :referral_phone_like,  -> (value) { where('LOWER(clients.referral_phone) LIKE ?', "%#{value.downcase}%") }

  scope :info_like,            -> (value) { where('LOWER(clients.relevant_referral_information) LIKE ?', "%#{value.downcase}%") }

  scope :slug_like,            -> (value) { where("LOWER(clients.slug) LIKE ?", "%#{value.downcase}%") }

  scope :find_by_family_id,    -> (value) { joins(cases: :family).where('families.id = ?', value).uniq }

  scope :is_received_by,       -> { joins(:received_by).pluck("CONCAT(users.first_name, ' ' ,users.last_name)", 'users.id').uniq }

  scope :referral_source_is,   -> { joins(:referral_source).pluck('referral_sources.name', 'referral_sources.id').uniq }

  scope :is_followed_up_by,    -> { joins(:followed_up_by).pluck("CONCAT(users.first_name, ' ' ,users.last_name)", 'users.id').uniq }

  scope :province_is,          -> { joins(:province).pluck('provinces.name', 'provinces.id').uniq }

  scope :accepted,             -> { where(state: 'accepted') }

  scope :rejected,             -> { where(state: 'rejected') }

  scope :male,                 -> { where(gender: 'male') }

  scope :female,               -> { where(gender: 'female') }

  scope :active_ec,            -> { where(status: 'Active EC') }

  scope :active_kc,            -> { where(status: 'Active KC') }

  scope :active_fc,            -> { where(status: 'Active FC') }

  scope :able,                 -> { where(able: true) }

  def reject?
    state_changed? && state == 'rejected'
  end

  def self.age_between(min_age, max_age)
    where(date_of_birth: max_age.years.ago.beginning_of_year..min_age.years.ago)
  end

  def name
    "#{first_name} #{last_name}"
  end

  def next_assessment_date
    return Date.today if assessments.count.zero?
    assessments.latest_record.created_at + 6.months
  end

  def next_appointment_date
    return Date.today if assessments.count.zero?

    last_assessment  = assessments.most_recents.first
    last_case_note   = case_notes.most_recents.first
    next_appointment = [last_assessment, last_case_note].compact.sort { |a, b| b.try(:created_at) <=> a.try(:created_at) }.first

    next_appointment.created_at + 1.month
  end

  def can_create_assessment?
    Date.today >= next_assessment_date
  end

  def can_create_case_note?
    assessments.count > 0
  end

  def self.able_managed_by(user)
    where('able = ? or user_id = ?', true, user.id)
  end

  def self.managed_by(user, status)
    where('status = ? or user_id = ?', status, user.id)
  end

  def reset_user_to_tasks
    tasks.update_all(user_id: user_id) if user_id_changed?
  end

  def has_no_ec_or_any_cases?
    cases.emergencies.blank? || cases.active.blank?
  end

  def has_no_active_kc_and_fc?
    cases.kinships.active.blank? && cases.fosters.active.blank?
  end

  def has_kc_and_fc?
    cases.kinships.present? && cases.fosters.present?
  end

  def has_no_kc_and_fc?
    !has_kc_or_fc?
  end

  def has_exited_kc_and_fc?
    cases.latest_kinship.exited && cases.latest_foster.exited
  end

  def has_kc_or_fc?
    cases.kinships.present? || cases.fosters.present?
  end

  def has_no_latest_kc_and_fc?
    !latest_case
  end

  def has_any_quarterly_reports?
    (cases.active.latest_kinship.present? && cases.latest_kinship.quarterly_reports.any?) || (cases.active.latest_foster.present? && cases.latest_foster.quarterly_reports.any?)
  end

  def latest_case
    cases.active.latest_kinship.presence || cases.active.latest_foster.presence
  end

  def age_as_years
    calculate_as('year')
  end

  def age_extra_months
    calculate_as('months')
  end

  def calculate_as(method)
    total_present_months = Date.today.year * 12 + Date.today.month
    total_dob_months     = date_of_birth.year * 12 + date_of_birth.month
    case method
    when 'year'
      (total_present_months - total_dob_months) / 12
    when 'months'
      (total_present_months - total_dob_months) % 12
    end
  end

  def able?
    able
  end

  def active_kc?
    status == 'Active KC'
  end

  def active_fc?
    status == 'Active FC'
  end

  def active_ec?
    status == 'Active EC'
  end

  def set_slug_as_alias
    self.slug = "#{ENV['ORGANISATION_ABBREVIATION']}-#{id}"
    self.save
  end
end
