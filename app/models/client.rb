class Client < ActiveRecord::Base
  include EntityTypeCustomField
  include NextClientEnrollmentTracking
  extend FriendlyId

  attr_reader :assessments_count
  attr_accessor :assessment_id
  attr_accessor :organization, :case_type

  friendly_id :slug, use: :slugged

  CLIENT_STATUSES = ['Referred', 'Active EC', 'Active KC', 'Active FC',
                      'Independent - Monitored', 'Exited - Dead',
                      'Exited - Age Out', 'Exited Independent', 'Exited Adopted',
                      'Exited Other'].freeze

  CLIENT_ACTIVE_STATUS = ['Active EC', 'Active FC', 'Active KC', 'Active'].freeze
  ABLE_STATES = %w(Accepted Rejected Discharged).freeze

  EXIT_STATUSES = CLIENT_STATUSES.select { |status| status if status.include?('Exited') || status.include?('Independent - Monitored')  }

  delegate :name, to: :donor, prefix: true, allow_nil: true

  belongs_to :referral_source,  counter_cache: true
  belongs_to :province,         counter_cache: true
  belongs_to :donor
  belongs_to :district
  belongs_to :received_by,      class_name: 'User',      foreign_key: 'received_by_id',    counter_cache: true
  belongs_to :followed_up_by,   class_name: 'User',      foreign_key: 'followed_up_by_id', counter_cache: true
  belongs_to :birth_province,   class_name: 'Province',  foreign_key: 'birth_province_id', counter_cache: true

  has_many :tasks,          dependent: :destroy
  has_many :agency_clients, dependent: :destroy
  has_many :agencies, through: :agency_clients
  has_many :client_quantitative_cases, dependent: :destroy
  has_many :quantitative_cases, through: :client_quantitative_cases
  has_many :custom_field_properties, as: :custom_formable, dependent: :destroy
  has_many :custom_fields, through: :custom_field_properties, as: :custom_formable
  has_many :client_enrollments, dependent: :destroy
  has_many :program_streams, through: :client_enrollments
  has_many :case_worker_clients, dependent: :destroy
  has_many :users, through: :case_worker_clients

  accepts_nested_attributes_for :tasks

  has_many :families,       through: :cases
  has_many :cases,          dependent: :destroy
  has_many :case_notes,     dependent: :destroy
  has_many :assessments,    dependent: :destroy
  # has_many :surveys,        dependent: :destroy
  has_many :progress_notes, dependent: :destroy

  has_many :client_client_types, dependent: :destroy
  has_many :client_types, through: :client_client_types
  has_many :client_interviewees, dependent: :destroy
  has_many :interviewees, through: :client_interviewees
  has_many :client_needs, dependent: :destroy
  has_many :needs, through: :client_needs
  has_many :client_problems, dependent: :destroy
  has_many :problems, through: :client_problems

  accepts_nested_attributes_for :client_needs
  accepts_nested_attributes_for :client_problems

  has_paper_trail

  validates :rejected_note, presence: true, on: :update, if: :reject?
  validates :exit_date, presence: true, on: :update, if: :exit_ngo?
  validates :exit_note, presence: true, on: :update, if: :exit_ngo?
  validates :kid_id, uniqueness: { case_sensitive: false }, if: 'kid_id.present?'
  validates :user_ids, presence: true

  after_create :set_slug_as_alias
  after_save :create_client_history
  after_update :notify_managers, if: :exiting_ngo?

  scope :live_with_like,              ->(value) { where('clients.live_with iLIKE ?', "%#{value}%") }
  scope :given_name_like,             ->(value) { where('clients.given_name iLIKE :value OR clients.local_given_name iLIKE :value', { value: "%#{value}%"}) }
  scope :family_name_like,            ->(value) { where('clients.family_name iLIKE :value OR clients.local_family_name iLIKE :value', { value: "%#{value}%"}) }
  scope :local_given_name_like,       ->(value) { where('clients.local_given_name iLIKE ?', "%#{value}%") }
  scope :local_family_name_like,      ->(value) { where('clients.local_family_name iLIKE ?', "%#{value}%") }
  scope :current_address_like,        ->(value) { where('clients.current_address iLIKE ?', "%#{value}%") }
  scope :house_number_like,           ->(value) { where('clients.house_number iLike ?', "%#{value}%") }
  scope :street_number_like,          ->(value) { where('clients.street_number iLike ?', "%#{value}%") }
  scope :village_like,                ->(value) { where('clients.village iLike ?', "%#{value}%") }
  scope :commune_like,                ->(value) { where('clients.commune iLike ?', "%#{value}%") }
  scope :school_name_like,            ->(value) { where('clients.school_name iLIKE ?', "%#{value}%") }
  scope :referral_phone_like,         ->(value) { where('clients.referral_phone iLIKE ?', "%#{value}%") }
  scope :info_like,                   ->(value) { where('clients.relevant_referral_information iLIKE ?', "%#{value}%") }
  scope :slug_like,                   ->(value) { where('clients.slug iLIKE ?', "%#{value}%") }
  scope :kid_id_like,                 ->(value) { where('clients.kid_id iLIKE ?', "%#{value}%") }
  scope :start_with_code,             ->(value) { where('clients.code iLIKE ?', "#{value}%") }
  scope :district_like,               ->(value) { joins(:district).where('districts.name iLike ?', "%#{value}%").uniq }
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
  scope :without_assessments,         ->        { includes(:assessments).where(assessments: { client_id: nil }) }
  scope :able,                        ->        { where(able_state: ABLE_STATES[0]) }
  scope :all_active_types,            ->        { where(status: CLIENT_ACTIVE_STATUS) }
  scope :of_case_worker,              -> (user_id) { joins(:case_worker_clients).where(case_worker_clients: { user_id: user_id }) }
  scope :exited_ngo,                  ->        { where(status: EXIT_STATUSES) }
  scope :non_exited_ngo,              ->        { where.not(status: EXIT_STATUSES) }
  scope :telephone_number_like,       ->(value) { where('clients.telephone_number iLIKE ?', "#{value}%") }

  def self.filter(options)
    query = all
    query = query.where("given_name iLIKE ?", "%#{fetch_75_chars_of(options[:given_name])}%")                 if options[:given_name].present?
    query = query.where("family_name iLIKE ?", "%#{fetch_75_chars_of(options[:family_name])}%")               if options[:family_name].present?
    query = query.where("local_given_name iLIKE ?", "%#{fetch_75_chars_of(options[:local_given_name])}%")     if options[:local_given_name].present?
    query = query.where("local_family_name iLIKE ?", "%#{fetch_75_chars_of(options[:local_family_name])}%")   if options[:local_family_name].present?
    query = query.where("village iLIKE ?", "%#{fetch_75_chars_of(options[:village])}%")                       if options[:village].present?
    query = query.where("commune iLIKE ?", "%#{fetch_75_chars_of(options[:commune])}%")                       if options[:commune].present?
    query = query.where("EXTRACT(MONTH FROM date_of_birth) = ? AND EXTRACT(YEAR FROM date_of_birth) = ?", Date.parse(options[:date_of_birth]).month, Date.parse(options[:date_of_birth]).year)  if options[:date_of_birth].present?


    query = query.where(birth_province_id: options[:birth_province_id])   if options[:birth_province_id].present?
    query = query.where(province_id: options[:current_province_id])       if options[:current_province_id].present?

    query
  end

  def self.fetch_75_chars_of(value)
    number_of_char = (value.length * 75) / 100
    value[0..(number_of_char-1)]
  end

  def reject?
    state_changed? && state == 'rejected'
  end

  def exit_ngo?
    EXIT_STATUSES.include?(status)
  end

  def self.age_between(min_age, max_age)
    min = (min_age * 12).to_i.months.ago.to_date
    max = (max_age * 12).to_i.months.ago.to_date
    where(date_of_birth: max..min)
  end

  def name
    name       = "#{given_name} #{family_name}"
    local_name = "#{local_given_name} #{local_family_name}"
    name.present? ? name : local_name.present? ? local_name : 'Unknown'
  end

  def en_and_local_name
    en_name = "#{given_name} #{family_name}"
    local_name = "#{local_given_name} #{local_family_name}"

    local_name.present? ? "#{en_name} (#{local_name})" : en_name.present? ? en_name : 'Unknown'
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
    return Date.today >= (assessments.latest_record.created_at + 3.months).to_date if assessments.count == 1
    true
  end

  def self.able_managed_by(user)
    where('able_state = ? or user_id = ?', ABLE_STATES[0], user.id)
  end

  def self.in_any_able_states_managed_by(user)
    joins(:case_worker_clients).where('able_state IN(?) OR case_worker_clients.user_id = ?', ABLE_STATES, user.id)
  end

  def self.managed_by(user, status)
    where('status = ? or user_id = ?', status, user.id)
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

  def age_as_years(date = Date.today)
    ((date - date_of_birth) / 365).to_i
  end

  def age_extra_months(date = Date.today)
    ((date - date_of_birth) % 365 / 31).to_i
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

  def active_case?
    active_ec? || active_fc? || active_kc?
  end

  def set_slug_as_alias
    paper_trail.without_versioning { |obj| obj.update_attributes(slug: "#{Organization.current.try(:short_name)}-#{id}") }
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
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      managers = User.ec_managers.pluck(:email).join(', ')
      admins   = User.admins.pluck(:email).join(', ')
      clients = active_ec.select { |client| client.active_day_care == day }

      if clients.present?
        ManagerMailer.remind_of_client(clients, day: day, manager: managers).deliver_now if managers.present?
        AdminMailer.remind_of_client(clients, day: day, admin: admins).deliver_now if admins.present?
      end
    end
  end

  def populate_needs
    Need.all.each do |need|
      client_needs.build(need: need)
    end
  end

  def populate_problems
    Problem.all.each do |problem|
      client_problems.build(problem: problem)
    end
  end

  def exiting_ngo?
    return false unless status_changed?
    EXIT_STATUSES.include?(status)
  end

  def self.notify_upcoming_csi_assessment
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      clients = joins(:assessments).all_active_types
      clients.each do |client|
        repeat_notifications = client.repeat_notifications_schedule

        if(repeat_notifications.include?(Date.today))
          CaseWorkerMailer.notify_upcoming_csi_weekly(client).deliver_now
        end
      end
    end
  end

  def most_recent_csi_assessment
    assessments.most_recents.first.created_at.to_date
  end

  def repeat_notifications_schedule
    most_recent_csi   = most_recent_csi_assessment

    notification_date = most_recent_csi + 5.months + 15.days
    next_one_week     = notification_date + 1.week
    next_two_weeks    = notification_date + 2.weeks
    next_three_weeks  = notification_date + 3.weeks
    next_four_weeks   = notification_date + 4.weeks
    next_five_weeks   = notification_date + 5.weeks
    next_six_weeks    = notification_date + 6.weeks
    next_seven_weeks  = notification_date + 7.weeks
    next_eight_weeks  = notification_date + 8.weeks

    [notification_date, next_one_week, next_two_weeks, next_three_weeks, next_four_weeks, next_five_weeks, next_six_weeks, next_seven_weeks, next_eight_weeks]
  end

  private

  def create_client_history
    ClientHistory.initial(self)
  end

  def notify_managers
    ClientMailer.exited_notification(self, User.managers.pluck(:email)).deliver_now
  end
end
