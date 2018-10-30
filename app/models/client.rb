class Client < ActiveRecord::Base
  include EntityTypeCustomField
  include NextClientEnrollmentTracking
  extend FriendlyId

  attr_reader :assessments_count
  attr_accessor :assessment_id
  attr_accessor :organization, :case_type

  friendly_id :slug, use: :slugged
  mount_uploader :profile, ImageUploader

  EXIT_REASONS    = ['Client is/moved outside NGO target area (within Cambodia)', 'Client is/moved outside NGO target area (International)', 'Client refused service', 'Client does not meet / no longer meets service criteria', 'Client died', 'Client does not require / no longer requires support', 'Agency lacks sufficient resources', 'Other']
  CLIENT_STATUSES = ['Accepted', 'Active', 'Exited', 'Referred'].freeze
  HEADER_COUNTS   = %w( case_note_date case_note_type exit_date accepted_date date_of_assessments program_streams programexitdate enrollmentdate).freeze

  GRADES = ['Kindergarten 1', 'Kindergarten 2', 'Kindergarten 3', 'Kindergarten 4', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', 'Year 1', 'Year 2', 'Year 3', 'Year 4', 'Year 5', 'Year 6', 'Year 7', 'Year 8'].freeze

  delegate :name, to: :referral_source, prefix: true, allow_nil: true
  delegate :name, to: :township, prefix: true, allow_nil: true
  delegate :name, to: :province, prefix: true, allow_nil: true
  delegate :name, to: :birth_province, prefix: true, allow_nil: true
  delegate :name, to: :district, prefix: true, allow_nil: true
  delegate :name, to: :subdistrict, prefix: true, allow_nil: true
  delegate :name, to: :state, prefix: true, allow_nil: true
  delegate :name_kh, to: :commune, prefix: true, allow_nil: true
  delegate :name_kh, to: :village, prefix: true, allow_nil: true

  belongs_to :referral_source,  counter_cache: true
  belongs_to :province,         counter_cache: true
  belongs_to :district
  belongs_to :subdistrict
  belongs_to :township
  belongs_to :state
  belongs_to :received_by,      class_name: 'User',      foreign_key: 'received_by_id',    counter_cache: true
  belongs_to :followed_up_by,   class_name: 'User',      foreign_key: 'followed_up_by_id', counter_cache: true
  belongs_to :birth_province,   class_name: 'Province',  foreign_key: 'birth_province_id', counter_cache: true
  belongs_to :commune
  belongs_to :village

  has_many :sponsors, dependent: :destroy
  has_many :donors, through: :sponsors
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
  has_many :enter_ngos, dependent: :destroy
  has_many :exit_ngos, dependent: :destroy
  has_many :referrals, dependent: :destroy
  has_many :government_forms, dependent: :destroy

  accepts_nested_attributes_for :tasks

  has_many :families,       through: :cases
  has_many :cases,          dependent: :destroy
  has_many :case_notes,     dependent: :destroy
  has_many :assessments,    dependent: :destroy

  has_paper_trail

  validates :kid_id, uniqueness: { case_sensitive: false }, if: 'kid_id.present?'
  validates :user_ids, presence: true, on: :create
  validates :user_ids, presence: true, on: :update, unless: :exit_ngo?
  validates :initial_referral_date, :received_by_id, :referral_source, :name_of_referee, :gender, presence: true

  before_create :set_country_origin
  before_update :disconnect_client_user_relation, if: :exiting_ngo?
  after_create :set_slug_as_alias
  after_save :create_client_history, :mark_referral_as_saved, :create_or_update_shared_client
  # after_update :notify_managers, if: :exiting_ngo?

  scope :given_name_like,                          ->(value) { where('clients.given_name iLIKE :value OR clients.local_given_name iLIKE :value', { value: "%#{value.squish}%"}) }
  scope :family_name_like,                         ->(value) { where('clients.family_name iLIKE :value OR clients.local_family_name iLIKE :value', { value: "%#{value.squish}%"}) }
  scope :local_given_name_like,                    ->(value) { where('clients.local_given_name iLIKE ?', "%#{value.squish}%") }
  scope :local_family_name_like,                   ->(value) { where('clients.local_family_name iLIKE ?', "%#{value.squish}%") }
  scope :slug_like,                                ->(value) { where('clients.slug iLIKE ?', "%#{value.squish}%") }
  scope :start_with_code,                          ->(value) { where('clients.code iLIKE ?', "#{value}%") }
  scope :find_by_family_id,                        ->(value) { joins(cases: :family).where('families.id = ?', value).uniq }
  scope :status_like,                              ->        { CLIENT_STATUSES }
  scope :is_received_by,                           ->        { joins(:received_by).pluck("CONCAT(users.first_name, ' ' , users.last_name)", 'users.id').uniq }
  scope :referral_source_is,                       ->        { joins(:referral_source).pluck('referral_sources.name', 'referral_sources.id').uniq }
  scope :is_followed_up_by,                        ->        { joins(:followed_up_by).pluck("CONCAT(users.first_name, ' ' , users.last_name)", 'users.id').uniq }
  scope :province_is,                              ->        { joins(:province).pluck('provinces.name', 'provinces.id').uniq }
  scope :birth_province_is,                        ->        { joins(:birth_province).pluck('provinces.name', 'provinces.id').uniq }
  scope :accepted,                                 ->        { where(state: 'accepted') }
  scope :rejected,                                 ->        { where(state: 'rejected') }
  scope :male,                                     ->        { where(gender: 'male') }
  scope :female,                                   ->        { where(gender: 'female') }
  scope :active_ec,                                ->        { where(status: 'Active EC') }
  scope :active_kc,                                ->        { where(status: 'Active KC') }
  scope :active_fc,                                ->        { where(status: 'Active FC') }
  scope :without_assessments,                      ->        { includes(:assessments).where(assessments: { client_id: nil }) }
  scope :active_status,                            ->        { where(status: 'Active') }
  scope :of_case_worker,                           -> (user_id) { joins(:case_worker_clients).where(case_worker_clients: { user_id: user_id }) }
  scope :exited_ngo,                               ->        { where(status: 'Exited') }
  scope :non_exited_ngo,                           ->        { where.not(status: ['Exited', 'Referred']) }
  scope :active_accepted_status,                   ->        { where(status: ['Active', 'Accepted']) }

  def self.filter(options)
    query = Client.all
    query = query.where("EXTRACT(MONTH FROM date_of_birth) = ? AND EXTRACT(YEAR FROM date_of_birth) = ?", Date.parse(options[:date_of_birth]).month, Date.parse(options[:date_of_birth]).year)  if options[:date_of_birth].present?
    query = query.joins(:commune).where("communes.name_en iLIKE ?", "%#{options[:commune].split(' / ').last}%")                 if options[:commune].present?
    query = query.joins(:village).where("villages.name_en iLIKE ?", "%#{options[:village].split(' / ').last}%")                 if options[:village].present?
    query = query.joins(:province).where("provinces.name iLIKE ?", "%#{options[:current_province]}%")         if options[:current_province].present?

    query.pluck(:slug)
  end

  def self.find_shared_client(options)
    current_org = Organization.current.short_name
    Organization.switch_to 'shared'
    shared_clients = SharedClient.all
    shared_clients = shared_clients.where("given_name iLIKE ?", "%#{fetch_75_chars_of(options[:given_name])}%")                 if options[:given_name].present?
    shared_clients = shared_clients.where("family_name iLIKE ?", "%#{fetch_75_chars_of(options[:family_name])}%")               if options[:family_name].present?
    shared_clients = shared_clients.where("local_given_name iLIKE ?", "%#{fetch_75_chars_of(options[:local_given_name])}%")     if options[:local_given_name].present?
    shared_clients = shared_clients.where("local_family_name iLIKE ?", "%#{fetch_75_chars_of(options[:local_family_name])}%")   if options[:local_family_name].present?
    shared_clients = shared_clients.joins(:birth_province).where("provinces.name iLIKE ?", "%#{options[:birth_province]}%")     if options[:birth_province].present?
    shared_clients = shared_clients.pluck(:slug)
    Organization.switch_to current_org
    shared_clients
  end

  def family
    Family.where('children && ARRAY[?]', id).last
  end

  def self.fetch_75_chars_of(value)
    number_of_char = (value.length * 75) / 100
    value[0..(number_of_char-1)]
  end

  def exit_ngo?
    status == 'Exited'
  end

  def referred?
    status == 'Referred'
  end

  def self.age_between(min_age, max_age)
    min = (min_age * 12).to_i.months.ago.to_date
    max = (max_age * 12).to_i.months.ago.to_date
    where(date_of_birth: max..min)
  end

  def name
    name       = "#{given_name} #{family_name}"
    local_name = "#{local_given_name} #{local_family_name}"
    name.present? ? name : local_name
  end

  def en_and_local_name
    en_name = "#{given_name} #{family_name}"
    local_name = "#{local_family_name} #{local_given_name}"
    if local_name.present? && en_name.present?
      "#{en_name} (#{local_name})"
    elsif local_name.present?
      local_name
    elsif en_name.present?
      en_name
    end
  end

  def local_name
    "#{local_family_name} #{local_given_name}"
  end

  def next_assessment_date
    return Date.today if assessments.count.zero?
    (assessments.latest_record.created_at + assessment_duration('max')).to_date
  end

  def next_appointment_date
    return Date.today if assessments.count.zero?

    last_assessment  = assessments.most_recents.first
    last_case_note   = case_notes.most_recents.first
    next_appointment = [last_assessment, last_case_note].compact.sort { |a, b| b.try(:created_at) <=> a.try(:created_at) }.first

    next_appointment.created_at + 1.month
  end

  def can_create_assessment?
    return Date.today >= (assessments.latest_record.created_at + assessment_duration('min')).to_date if assessments.count == 1
    true
  end

  def next_case_note_date
    return Date.today if case_notes.count.zero? || case_notes.latest_record.try(:meeting_date).nil?
    setting = Setting.first
    max_case_note = setting.try(:max_case_note) || 30
    case_note_frequency = setting.try(:case_note_frequency) || 'day'
    case_note_period = max_case_note.send(case_note_frequency)
    (case_notes.latest_record.meeting_date + case_note_period).to_date
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
    status == 'Active'
  end

  def set_slug_as_alias
    return if slug.present?
    paper_trail.without_versioning { |obj| obj.update_columns(slug: "#{Organization.current.try(:short_name)}-#{id}") }
  end

  def time_in_care
    date_time_in_care = { years: 0, months: 0, weeks: 0, days: 0 }
    return date_time_in_care unless client_enrollments.any?
    first_multi_enrolled_program_date = ''
    last_multi_leave_program_date = ''
    ordered_enrollments = client_enrollments.order(:enrollment_date)
    ordered_enrollments.each_with_index do |enrollment, index|
      current_enrollment_date = enrollment.enrollment_date
      current_program_exit_date = enrollment.leave_program.try(:exit_date) || Date.today

      next_program_enrollment = ordered_enrollments[index + 1].nil? ? ordered_enrollments[index - 1] : ordered_enrollments[index + 1]
      next_program_enrollment_date = next_program_enrollment.enrollment_date
      next_program_exit_date = next_program_enrollment.leave_program.try(:exit_date) || Date.today

      if current_program_exit_date <= next_program_enrollment_date
        if first_multi_enrolled_program_date.present? && last_multi_leave_program_date.present?
          date_time_in_care = calculate_time_in_care(date_time_in_care, first_multi_enrolled_program_date, last_multi_leave_program_date)

          first_multi_enrolled_program_date = ''
          last_multi_leave_program_date = ''
        end
        date_time_in_care = calculate_time_in_care(date_time_in_care, current_enrollment_date, current_program_exit_date)
      else
        first_multi_enrolled_program_date = current_enrollment_date if first_multi_enrolled_program_date == ''
        last_multi_leave_program_date = current_program_exit_date > next_program_exit_date ? current_program_exit_date : next_program_exit_date

        if index == ordered_enrollments.length - 1
          date_time_in_care = calculate_time_in_care(date_time_in_care, first_multi_enrolled_program_date, last_multi_leave_program_date)
        end
      end
    end
    date_time_in_care.store(:years, 0) unless date_time_in_care[:years].present?
    date_time_in_care.store(:months, 0) unless date_time_in_care[:months].present?
    date_time_in_care.store(:weeks, 0) unless date_time_in_care[:weeks].present?
    date_time_in_care.store(:days, 0) unless date_time_in_care[:days].present?

    if date_time_in_care[:days] > 0
      date_time_in_care[:weeks] = date_time_in_care[:weeks] + 1
      date_time_in_care[:days] = 0
    end
    if date_time_in_care[:weeks] >= 4
      date_time_in_care[:weeks] = date_time_in_care[:weeks] - 4
      date_time_in_care[:months] = date_time_in_care[:months] + 1
    end
    if date_time_in_care[:months] >= 12
      date_time_in_care[:months] = date_time_in_care[:months] - 12
      date_time_in_care[:years] = date_time_in_care[:years] + 1
    end
    date_time_in_care
  end

  def self.exit_in_week(number_of_day)
    date = number_of_day.day.ago.to_date
    active_status.joins(:cases).where(cases: { case_type: 'EC', start_date: date, exited: false })
  end

  # def self.ec_reminder_in(day)
  #   Organization.all.each do |org|
  #     Organization.switch_to org.short_name
  #     managers = User.non_locked.ec_managers.pluck(:email).join(', ')
  #     admins   = User.non_locked.admins.pluck(:email).join(', ')
  #     clients = Client.active_status.joins(:cases).where(cases: { case_type: 'EC', exited: false}).uniq
  #     clients = clients.select { |client| client.active_day_care == day }
  #
  #     if clients.present?
  #       ManagerMailer.remind_of_client(clients, day: day, manager: managers).deliver_now if managers.present?
  #       AdminMailer.remind_of_client(clients, day: day, admin: admins).deliver_now if admins.present?
  #     end
  #   end
  # end

  def exiting_ngo?
    return false unless status_changed?
    status == 'Exited'
  end

  def self.notify_upcoming_csi_assessment
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      next if Setting.first.try(:disable_assessment)
      clients = joins(:assessments).active_accepted_status
      clients.each do |client|
        next if client.uneligible_age?
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

  def uneligible_age?
    return false unless date_of_birth.present?
    age = Setting.first.try(:age) || 18
    client_age = age_as_years
    client_age >= age ? true : false
  end

  def country_origin_label
    country_origin.present? ? country_origin : 'cambodia'
  end

  def family
    Family.where('children && ARRAY[?]', id).last
  end

  private

  def create_client_history
    ClientHistory.initial(self)
  end

  def notify_managers
    ClientMailer.exited_notification(self, User.managers.non_locked.pluck(:email)).deliver_now
  end

  def disconnect_client_user_relation
    case_worker_clients.destroy_all
  end

  def assessment_duration(duration)
    if duration == 'max'
      setting = Setting.first
      assessment_period = (setting.try(:max_assessment) || 6)
      assessment_frequency = setting.try(:assessment_frequency) || 'month'
    else
      assessment_period = 3
      assessment_frequency = 'month'
    end
    assessment_period = assessment_period.send(assessment_frequency)
  end

  def mark_referral_as_saved
    referral = Referral.find_by(slug: slug, saved: false)
    referral.update_attributes(client_id: id, saved: true) if referral.present?
  end

  def create_or_update_shared_client
    current_org = Organization.current
    client = self.slice(:given_name, :family_name, :local_given_name, :local_family_name, :gender, :date_of_birth, :telephone_number, :live_with, :slug, :birth_province_id, :country_origin)
    suburb = self.suburb
    state_name = self.state_name

    Organization.switch_to 'shared'
    if suburb.present?
      province = Province.find_or_create_by(name: suburb, country: 'lesotho')
      client['birth_province_id'] = province.id
    elsif state_name.present?
      province = Province.find_or_create_by(name: state_name, country: 'myanmar')
      client['birth_province_id'] = province.id
    end
    shared_client = SharedClient.find_by(slug: client['slug'])
    shared_client.present? ? shared_client.update(client) : SharedClient.create(client)
    Organization.switch_to current_org.short_name
  end

  def set_country_origin
    return if country_origin.present?
    country = Setting.first.try(:country_name)
    self.country_origin = country
  end

  def calculate_time_in_care(date_time_in_care, from_time, to_time)
    to_time = to_time + date_time_in_care[:years].years unless date_time_in_care[:years].nil?
    to_time = to_time + date_time_in_care[:months].months unless date_time_in_care[:months].nil?
    to_time = to_time + date_time_in_care[:weeks].weeks unless date_time_in_care[:weeks].nil?
    to_time = to_time + date_time_in_care[:days].days unless date_time_in_care[:days].nil?
    ActionController::Base.helpers.distance_of_time_in_words_hash(from_time, to_time, :except => [:seconds, :minutes, :hours])
  end
end
