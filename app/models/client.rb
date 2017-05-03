class Client < ActiveRecord::Base
  include EntityTypeCustomField
  include EntityTypeCustomFieldNotification
  extend FriendlyId

  attr_reader :assessments_count
  attr_accessor :assessment_id
  attr_accessor :organization, :case_type

  friendly_id :slug, use: :slugged

  CLIENT_STATUSES = ['Referred', 'Active EC', 'Active KC', 'Active FC',
                      'Independent - Monitored', 'Exited - Deseased',
                      'Exited - Age Out', 'Exited Independent', 'Exited Adopted',
                      'Exited Other'].freeze

  CLIENT_ACTIVE_STATUS = ['Active EC', 'Active FC', 'Active KC'].freeze
  ABLE_STATES = %w(Accepted Rejected Discharged).freeze

  EXIT_STATUSES = CLIENT_STATUSES.select { |status| status if status.include?('Exited') }

  delegate :name, to: :donor, prefix: true, allow_nil: true

  belongs_to :referral_source,  counter_cache: true
  belongs_to :province,         counter_cache: true
  belongs_to :user,             counter_cache: true
  belongs_to :donor
  belongs_to :received_by,      class_name: 'User',     foreign_key: 'received_by_id',    counter_cache: true
  belongs_to :followed_up_by,   class_name: 'User',     foreign_key: 'followed_up_by_id', counter_cache: true
  belongs_to :birth_province,   class_name: 'Province', foreign_key: 'birth_province_id', counter_cache: true

  has_one  :government_report, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :able_screening_questions, through: :answers
  has_many :tasks,          dependent: :destroy
  has_many :agency_clients
  has_many :agencies, through: :agency_clients
  has_many :client_quantitative_cases
  has_many :quantitative_cases, through: :client_quantitative_cases
  has_many :custom_field_properties, as: :custom_formable, dependent: :destroy
  has_many :custom_fields, through: :custom_field_properties, as: :custom_formable

  accepts_nested_attributes_for :tasks
  accepts_nested_attributes_for :answers
  accepts_nested_attributes_for :tasks

  has_many :cases,          dependent: :destroy
  has_many :families, through: :cases
  has_many :case_notes,     dependent: :destroy
  has_many :assessments,    dependent: :destroy
  has_many :surveys,        dependent: :destroy
  has_many :progress_notes, dependent: :destroy

  has_paper_trail

  validates :rejected_note, presence: true, on: :update, if: :reject?

  before_update :reset_user_to_tasks

  after_create :set_slug_as_alias
  after_update :set_able_status, if: proc { |client| client.able_state.blank? && answers.any? }

  scope :given_name_like,             ->(value) { where('clients.given_name iLIKE ?', "%#{value}%") }
  scope :family_name_like,            ->(value) { where('clients.family_name iLIKE ?', "%#{value}%") }
  scope :local_given_name_like,       ->(value) { where('clients.local_given_name iLIKE ?', "%#{value}%") }
  scope :local_family_name_like,      ->(value) { where('clients.local_family_name iLIKE ?', "%#{value}%") }
  scope :current_address_like,        ->(value) { where('clients.current_address iLIKE ?', "%#{value}%") }
  scope :school_name_like,            ->(value) { where('clients.school_name iLIKE ?', "%#{value}%") }
  scope :referral_phone_like,         ->(value) { where('clients.referral_phone iLIKE ?', "%#{value}%") }
  scope :info_like,                   ->(value) { where('clients.relevant_referral_information iLIKE ?', "%#{value}%") }
  scope :slug_like,                   ->(value) { where('clients.slug iLIKE ?', "%#{value}%") }
  scope :kid_id_like,                 ->(value) { where('clients.kid_id iLIKE ?', "%#{value}%") }
  scope :start_with_code,             ->(value) { where('clients.code iLIKE ?', "#{value}%") }
  scope :find_by_family_id,           ->(value) { joins(cases: :family).where('families.id = ?', value).uniq }
  scope :status_like,                 ->        { CLIENT_STATUSES }
  scope :is_received_by,              ->        { joins(:received_by).pluck("CONCAT(users.first_name, ' ' , users.last_name)", 'users.id').uniq }
  scope :referral_source_is,          ->        { joins(:referral_source).pluck('referral_sources.name', 'referral_sources.id').uniq }
  scope :is_followed_up_by,           ->        { joins(:followed_up_by).pluck("CONCAT(users.first_name, ' ' , users.last_name)", 'users.id').uniq }
  scope :province_is,                 ->        { joins(:province).pluck('provinces.name', 'provinces.id').uniq }
  scope :accepted,                    ->        { where(state: 'accepted') }
  scope :rejected,                    ->        { where(state: 'rejected') }
  scope :male,                        ->        { where(gender: 'male') }
  scope :female,                      ->        { where(gender: 'female') }
  scope :active_ec,                   ->        { where(status: 'Active EC') }
  scope :active_kc,                   ->        { where(status: 'Active KC') }
  scope :active_fc,                   ->        { where(status: 'Active FC') }
  scope :without_assessments,         ->        { includes(:assessments).where(assessments:         { client_id: nil }) }
  scope :able,                        ->        { where(able_state: ABLE_STATES[0]) }
  scope :all_active_types,            ->        { where(status: CLIENT_ACTIVE_STATUS) }

  def self.filter(options)
    query = all

    query = query.where(given_name: options[:given_name])                 if options[:given_name].present?
    query = query.where(date_of_birth: options[:date_of_birth])           if options[:date_of_birth].present?
    query = query.where(gender: options[:gender])                         if options[:gender].present?
    query = query.where(birth_province_id: options[:birth_province_id])   if options[:birth_province_id].present?

    query
  end

  def reject?
    state_changed? && state == 'rejected'
  end

  def self.age_between(min_age, max_age)
    min = (min_age * 12).to_i.months.ago.to_date.end_of_month
    max = (max_age * 12).to_i.months.ago.to_date.beginning_of_month
    where(date_of_birth: max..min)
  end

  def name
    name       = "#{given_name} #{family_name}"
    local_name = "#{local_given_name} #{local_family_name}"
    name.present? ? name : local_name
  end

  def self.next_assessment_candidates
    Assessment.where('client IN (?) AND ', self)
  end

  def next_assessment_date
    return Date.today if assessments.count.zero?
    (assessments.latest_record.created_at + 6.months).to_date
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
    where('able_state = ? or user_id = ?', ABLE_STATES[0], user.id)
  end

  def self.in_any_able_states_managed_by(user)
    where('user_id = ? OR able_state IN(?)', user.id, ABLE_STATES)
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
    able_state == ABLE_STATES[0]
  end

  def rejected?
    able_state == ABLE_STATES[1]
  end

  def discharged?
    able_state == ABLE_STATES[2]
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
    paper_trail.without_versioning { |obj| obj.update_attributes(slug: "#{Organization.current.try(:short_name)}-#{id}") }
  end

  def set_able_status
    update(able_state: ABLE_STATES[0]) if AbleScreeningQuestion.has_alert_manager?(self) && answers.include_yes?
  end

  def time_in_care
    if cases.any?
      if cases.active.any?
        (active_day_care / 365).round(1)
      else
        (inactive_day_care / 365).round(1)
      end
    else
      nil
    end
  end

  def self.exit_in_week(number_of_day)
    date = number_of_day.day.ago.to_date
    active_ec.joins(:cases).where(cases: { case_type: 'EC', start_date: date })
  end

  def active_day_care
    active_cases      = cases.active.order(:created_at)
    first_active_case = active_cases.first

    start_date        = first_active_case.start_date.to_date
    current_date      = Date.today.to_date
    (current_date - start_date).to_f
  end

  def inactive_day_care
    inactive_cases     = cases.inactive.order(:updated_at)
    last_inactive_case = inactive_cases.last
    end_date           = last_inactive_case.exit_date.to_date

    first_case         = cases.inactive.order(:created_at).first
    start_date         = first_case.start_date.to_date

    (end_date - start_date).to_f
  end

  def self.ec_reminder_in(day)
    managers = User.ec_managers.pluck(:email).join(', ')
    admins   = User.admins.pluck(:email).join(', ')
    clients = active_ec.select { |client| client.active_day_care == day }

    if clients.present?
      ManagerMailer.remind_of_client(clients, day: day, manager: managers).deliver_now if managers.present?
      AdminMailer.remind_of_client(clients, day: day, admin: admins).deliver_now if admins.present?
    end
  end
end
