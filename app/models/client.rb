class Client < ActiveRecord::Base
  include EntityTypeCustomField
  include NextClientEnrollmentTracking
  extend FriendlyId

  require 'text'

  attr_reader :assessments_count
  attr_accessor :assessment_id
  attr_accessor :organization, :case_type

  friendly_id :slug, use: :slugged
  mount_uploader :profile, ImageUploader

  EXIT_REASONS    = ['Client is/moved outside NGO target area (within Cambodia)', 'Client is/moved outside NGO target area (International)', 'Client refused service', 'Client does not meet / no longer meets service criteria', 'Client died', 'Client does not require / no longer requires support', 'Agency lacks sufficient resources', 'Other']
  CLIENT_STATUSES = ['Accepted', 'Active', 'Exited', 'Referred'].freeze
  HEADER_COUNTS   = %w( case_note_date case_note_type exit_date accepted_date date_of_assessments date_of_custom_assessments program_streams programexitdate enrollmentdate quantitative-type).freeze

  GRADES = ['Kindergarten 1', 'Kindergarten 2', 'Kindergarten 3', 'Kindergarten 4', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', 'Year 1', 'Year 2', 'Year 3', 'Year 4', 'Year 5', 'Year 6', 'Year 7', 'Year 8'].freeze
  GENDER_OPTIONS  = ['female', 'male', 'other', 'unknown']
  CLIENT_LEVELS   = ['No', 'Level 1', 'Level 2']

  delegate :name, to: :referral_source, prefix: true, allow_nil: true
  delegate :name, to: :township, prefix: true, allow_nil: true
  delegate :name, to: :province, prefix: true, allow_nil: true
  delegate :name, to: :birth_province, prefix: true, allow_nil: true
  delegate :name, to: :district, prefix: true, allow_nil: true
  delegate :name, to: :subdistrict, prefix: true, allow_nil: true
  delegate :name, to: :state, prefix: true, allow_nil: true
  delegate :name_kh, to: :commune, prefix: true, allow_nil: true
  delegate :name_kh, to: :village, prefix: true, allow_nil: true
  delegate :name_en, to: :commune, prefix: true, allow_nil: true
  delegate :name_en, to: :village, prefix: true, allow_nil: true

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
  has_many :users, through: :case_worker_clients, validate: false
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
  validates :initial_referral_date, :received_by_id, :name_of_referee, :gender, :referral_source_category_id, presence: true

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
  scope :referral_source_is,                       ->        { joins(:referral_source).where.not('referral_sources.name in (?)', ReferralSource::REFERRAL_SOURCES).pluck('referral_sources.name', 'referral_sources.id').uniq }
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

  def self.find_shared_client(options)
    similar_fields = []
    shared_clients = []
    current_org    = Organization.current.short_name
    Organization.switch_to 'shared'
    skip_orgs_percentage = Organization.skip_dup_checking_orgs.map {|val| "%#{val.short_name}%" }
    if skip_orgs_percentage.any?
      shared_clients       = SharedClient.where.not('archived_slug ILIKE ANY ( array[?] )', skip_orgs_percentage).pluck(:duplicate_checker)
    else
      shared_clients       = SharedClient.all.pluck(:duplicate_checker)
    end

    Organization.switch_to current_org

    shared_clients.compact.each do |client|
      client = client.split('&')
      input_name_field     = "#{options[:given_name]} #{options[:family_name]} #{options[:local_family_name]} #{options[:local_given_name]}".squish
      client_name_field    = client[0].squish

      field_name = compare_matching(input_name_field, client_name_field)
      dob        = date_of_birth_matching(options[:date_of_birth], client.last.squish)
      cp         = client_address_matching(options[:current_province], client[4].squish)
      cd         = client_address_matching(options[:district], client[3].squish)
      cc         = client_address_matching(options[:commune], client[2].squish)
      cv         = client_address_matching(options[:village], client[1].squish)
      bp         = birth_province_matching(options[:birth_province], client[5].squish)

      match_percentages = [field_name, dob, cp, cd, cc, cv, bp]

      if match_percentages.compact.present?
        if match_percentages.compact.inject(:*) * 100 >= 75
          similar_fields << '#hidden_name_fields' if match_percentages[0].present?
          similar_fields << '#hidden_date_of_birth' if match_percentages[1].present?
          similar_fields << '#hidden_province' if match_percentages[2].present?
          similar_fields << '#hidden_district' if match_percentages[3].present?
          similar_fields << '#hidden_commune' if match_percentages[4].present?
          similar_fields << '#hidden_village' if match_percentages[5].present?
          similar_fields << '#hidden_birth_province' if match_percentages[6].present?
        end
      end
    end

    similar_fields.uniq
  end

  def family
    Family.where('children && ARRAY[?]', id).last
  end

  def self.fetch_75_chars_of(value)
    number_of_char = (value.length * 75) / 100
    value[0..(number_of_char-1)]
  end

  def self.client_address_matching(value1, value2)
    return nil if value1.blank?
    value1 == value2 ? 1 : 0.91
  end

  def self.birth_province_matching(value1, value2)
    return nil if value1.blank?
    value1 == value2 ? 1 : 0.85
  end

  def self.compare_matching(value1, value2)
    return nil if value1.blank?
    white      = Text::WhiteSimilarity.new
    percentage = white.similarity(value1, value2)
    percentage < 0 ? 0 : percentage
  end

  def self.date_of_birth_matching(dob1, dob2)
    return nil if dob1.blank? || dob2.nil? || dob1.nil? || dob2.blank?
    percentage = 0
    if dob1.to_date == dob2.to_date
      percentage = 1
    else
      remain_day = (dob1.to_date > dob2.to_date) ? (dob1.to_date - dob2.to_date) : (dob2.to_date - dob1.to_date)
      percentage = 1 - (remain_day * 0.5)/100 if remain_day.present?
    end

    percentage < 0 ? nil : percentage
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

  def latin_name_with_id
    "#{given_name} #{family_name} (#{id})"
  end

  def next_assessment_date(user_activated_date = nil)
    return Date.today if assessments.defaults.empty?
    return nil if user_activated_date.present? && assessments.defaults.latest_record.created_at < user_activated_date
    (assessments.defaults.latest_record.created_at + assessment_duration('max')).to_date
  end

  def custom_next_assessment_date(user_activated_date = nil)
    return Date.today if assessments.customs.empty?
    return nil if user_activated_date.present? && assessments.customs.latest_record.created_at < user_activated_date
    (assessments.customs.latest_record.created_at + assessment_duration('max', false)).to_date
  end

  def next_appointment_date
    return Date.today if assessments.count.zero?

    last_assessment  = assessments.most_recents.first
    last_case_note   = case_notes.most_recents.first
    next_appointment = [last_assessment, last_case_note].compact.sort { |a, b| b.try(:created_at) <=> a.try(:created_at) }.first

    next_appointment.created_at + 1.month
  end


  def can_create_assessment?(default)
    if default
      if assessments.defaults.count == 1
        return (Date.today >= (assessments.defaults.latest_record.created_at + assessment_duration('min')).to_date) && assessments.defaults.latest_record.completed?
      elsif assessments.defaults.count >= 2
        return assessments.defaults.latest_record.completed?
      end
    else
      if assessments.customs.count == 1
        return (Date.today >= (assessments.customs.latest_record.created_at + assessment_duration('min', false)).to_date) && assessments.customs.latest_record.completed?
      elsif assessments.customs.count >= 2
        return assessments.customs.latest_record.completed?
      end
    end
    true
  end

  def next_case_note_date(user_activated_date = nil)
    return Date.today if case_notes.count.zero? || case_notes.latest_record.try(:meeting_date).nil?
    return nil if case_notes.latest_record.created_at < user_activated_date if user_activated_date.present?
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
    org = Organization.current
    if archived_slug.present?
      if slug.in? Client.pluck(:slug)
        random_char = slug.split('-')[0]
        paper_trail.without_versioning { |obj| obj.update_columns(slug: "#{random_char}-#{id}") }
      end
    else
      random_char = generate_random_char
      Organization.switch_to org.short_name
      paper_trail.without_versioning { |obj| obj.update_columns(slug: "#{random_char}-#{id}", archived_slug: "#{Organization.current.try(:short_name)}-#{id}") }
    end
  end

  def generate_random_char
    Organization.switch_to 'shared'
    loop do
      char = ('a'..'z').to_a.sample(3).join()
      break char unless SharedClient.find_by(slug: "#{char}-#{id}").present?
    end
  end

  def time_in_ngo
    return {} if self.status == 'Referred'
    date_time_in_ngo = { years: 0, months: 0, weeks: 0, days: 0 }
    detail_time_in_ngo = []

    if exit_ngos.any?
      exit_dates  = exit_ngos.order(:exit_date).pluck(:exit_date)
      enter_dates = enter_ngos.order(:accepted_date).pluck(:accepted_date)
      Client.find(self.id).enter_ngos.order(accepted_date: :asc).each_with_index do |enter_ngo, index|
        if enter_dates.size > exit_dates.size
          if exit_dates[index + 1].present? || exit_dates[index].present?
            detail_time_in_ngo << calculate_time_in_care(date_time_in_ngo, exit_dates[index], enter_ngo.accepted_date)
          else
            detail_time_in_ngo << calculate_time_in_care(date_time_in_ngo, Date.today, enter_ngo.accepted_date)
          end
        elsif exit_dates.size == enter_dates.size
          detail_time_in_ngo << calculate_time_in_care(date_time_in_ngo, exit_dates[index], enter_ngo.accepted_date)
        end
      end
    else
      detail_time_in_ngo << calculate_time_in_care(date_time_in_ngo, Date.today, enter_ngos.first.accepted_date)
    end


    detail_time = { years: 0, months: 0, weeks: 0, days: 0 }

    detail_time_in_ngo.each do |time|
      detail_time[:years] += time[:years].present? ? time[:years] : 0
      detail_time[:months] += time[:months].present? ? time[:months] : 0
      detail_time[:weeks] += time[:weeks].present? ? time[:weeks] : 0
      detail_time[:days] += time[:days].present? ? time[:days] : 0
    end

    detail_time.store(:years, 0) unless detail_time[:years].present?
    detail_time.store(:months, 0) unless detail_time[:months].present?
    detail_time.store(:weeks, 0) unless detail_time[:weeks].present?
    detail_time.store(:days, 0) unless detail_time[:days].present?

    if detail_time[:days] / 7 > 0
      detail_time[:weeks] = detail_time[:weeks] + detail_time[:days] / 7
      detail_time[:days] = detail_time[:days] % 7
    else
      detail_time[:weeks] = detail_time[:weeks] + 1
      detail_time[:days] = 0
    end

    if detail_time[:weeks] / 4 > 0
      week_time = detail_time[:weeks]
      detail_time[:weeks] = detail_time[:weeks] - ((detail_time[:weeks] / 4) * 4)
      detail_time[:months] = detail_time[:months] + week_time / 4
    end

    if detail_time[:months] / 12 > 0
      month_time = detail_time[:months]
      detail_time[:months] = detail_time[:months] - (detail_time[:months] / 12 ) * 12
      detail_time[:years] = detail_time[:years] + month_time / 12
    end
    detail_time
  end

  def time_in_cps
    date_time_in_cps   = { years: 0, months: 0, weeks: 0, days: 0 }
    return nil unless client_enrollments.present?
    enrollments = client_enrollments.order(:program_stream_id)
    detail_cps = {}

    enrollments.each_with_index do |enrollment, index|
      enroll_date     = enrollment.enrollment_date
      current_or_exit = enrollment.leave_program.try(:exit_date) || Date.today

      if enrollments[index - 1].present? && enrollments[index - 1].program_stream_name == enrollment.program_stream_name
        date_time_in_cps = calculate_time_in_care(date_time_in_cps, current_or_exit, enroll_date)
      else
        date_time_in_cps = { years: 0, months: 0, weeks: 0, days: 0 }
        date_time_in_cps = calculate_time_in_care(date_time_in_cps, current_or_exit, enroll_date)
      end

      if detail_cps["#{enrollment.program_stream_name}"].present?
        detail_cps["#{enrollment.program_stream_name}"][:years].present? ? detail_cps["#{enrollment.program_stream_name}"][:years] : detail_cps["#{enrollment.program_stream_name}"][:years] = 0
        detail_cps["#{enrollment.program_stream_name}"][:months].present? ? detail_cps["#{enrollment.program_stream_name}"][:months] : detail_cps["#{enrollment.program_stream_name}"][:months] = 0
        detail_cps["#{enrollment.program_stream_name}"][:weeks].present? ? detail_cps["#{enrollment.program_stream_name}"][:weeks] : detail_cps["#{enrollment.program_stream_name}"][:weeks] = 0
        detail_cps["#{enrollment.program_stream_name}"][:days].present? ? detail_cps["#{enrollment.program_stream_name}"][:days] : detail_cps["#{enrollment.program_stream_name}"][:days] = 0

        detail_cps["#{enrollment.program_stream_name}"][:years] += date_time_in_cps[:years].present? ? date_time_in_cps[:years] : 0
        detail_cps["#{enrollment.program_stream_name}"][:months] += date_time_in_cps[:months].present? ? date_time_in_cps[:months] : 0
        detail_cps["#{enrollment.program_stream_name}"][:weeks] += date_time_in_cps[:weeks].present? ? date_time_in_cps[:weeks] : 0
        detail_cps["#{enrollment.program_stream_name}"][:days] += date_time_in_cps[:days].present? ? date_time_in_cps[:days] : 0
      else
        detail_cps["#{enrollment.program_stream_name}"] = date_time_in_cps
      end
    end

    detail_cps.values.map do |value|
      next if value.blank?
      value.store(:years, 0) unless value[:years].present?
      value.store(:months, 0) unless value[:months].present?
      value.store(:weeks, 0) unless value[:weeks].present?
      value.store(:days, 0) unless value[:days].present?

      if value[:days] > 0
        value[:weeks] = value[:weeks] + 1
        value[:days] = 0
      end
      if value[:weeks] >= 4
        value[:weeks] = value[:weeks] - 4
        value[:months] = value[:months] + 1
      end
      if value[:months] >= 12
        value[:months] = value[:months] - 12
        value[:years] = value[:years] + 1
      end
    end

    detail_cps
  end

  # def time_in_care
  #   date_time_in_care = { years: 0, months: 0, weeks: 0, days: 0 }
  #   return date_time_in_care unless client_enrollments.any?
  #   first_multi_enrolled_program_date = ''
  #   last_multi_leave_program_date = ''
  #   ordered_enrollments = client_enrollments.order(:enrollment_date)
  #   ordered_enrollments.each_with_index do |enrollment, index|
  #     current_enrollment_date = enrollment.enrollment_date
  #     current_program_exit_date = enrollment.leave_program.try(:exit_date) || Date.today

  #     next_program_enrollment = ordered_enrollments[index + 1].nil? ? ordered_enrollments[index - 1] : ordered_enrollments[index + 1]
  #     next_program_enrollment_date = next_program_enrollment.enrollment_date
  #     next_program_exit_date = next_program_enrollment.leave_program.try(:exit_date) || Date.today

  #     if current_program_exit_date <= next_program_enrollment_date
  #       if first_multi_enrolled_program_date.present? && last_multi_leave_program_date.present?
  #         date_time_in_care = calculate_time_in_care(date_time_in_care, first_multi_enrolled_program_date, last_multi_leave_program_date)

  #         first_multi_enrolled_program_date = ''
  #         last_multi_leave_program_date = ''
  #       end
  #       date_time_in_care = calculate_time_in_care(date_time_in_care, current_enrollment_date, current_program_exit_date)
  #     else
  #       first_multi_enrolled_program_date = current_enrollment_date if first_multi_enrolled_program_date == ''
  #       last_multi_leave_program_date = current_program_exit_date > next_program_exit_date ? current_program_exit_date : next_program_exit_date

  #       if index == ordered_enrollments.length - 1
  #         date_time_in_care = calculate_time_in_care(date_time_in_care, first_multi_enrolled_program_date, last_multi_leave_program_date)
  #       end
  #     end
  #   end
  #   date_time_in_care.store(:years, 0) unless date_time_in_care[:years].present?
  #   date_time_in_care.store(:months, 0) unless date_time_in_care[:months].present?
  #   date_time_in_care.store(:weeks, 0) unless date_time_in_care[:weeks].present?
  #   date_time_in_care.store(:days, 0) unless date_time_in_care[:days].present?

  #   if date_time_in_care[:days] > 0
  #     date_time_in_care[:weeks] = date_time_in_care[:weeks] + 1
  #     date_time_in_care[:days] = 0
  #   end
  #   if date_time_in_care[:weeks] >= 4
  #     date_time_in_care[:weeks] = date_time_in_care[:weeks] - 4
  #     date_time_in_care[:months] = date_time_in_care[:months] + 1
  #   end
  #   if date_time_in_care[:months] >= 12
  #     date_time_in_care[:months] = date_time_in_care[:months] - 12
  #     date_time_in_care[:years] = date_time_in_care[:years] + 1
  #   end
  #   date_time_in_care
  # end

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
      next if !(Setting.first.enable_default_assessment) && !(Setting.first.enable_custom_assessment)
      clients = joins(:assessments).active_accepted_status
      clients.each do |client|
        if Setting.first.enable_default_assessment && client.eligible_default_csi? && client.assessments.defaults.any?
          repeat_notifications = client.repeat_notifications_schedule
          if(repeat_notifications.include?(Date.today))
            CaseWorkerMailer.notify_upcoming_csi_weekly(client).deliver_now
          end
        end
        if Setting.first.enable_custom_assessment && client.eligible_custom_csi? && client.assessments.customs.any?
          repeat_notifications = client.repeat_notifications_schedule(false)
          if(repeat_notifications.include?(Date.today))
            CaseWorkerMailer.notify_upcoming_csi_weekly(client).deliver_now
          end
        end
      end
    end
  end

  def self.notify_incomplete_daily_csi_assessment
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      if Setting.first.enable_default_assessment
        clients = joins(:assessments).where(assessments: { completed: false, default: true })
        clients.each do |client|
          if client.eligible_default_csi? && client.assessments.defaults.any?
            CaseWorkerMailer.notify_incomplete_daily_csi_assessments(client).deliver_now
          end
        end
      end

      if Setting.first.enable_custom_assessment
        clients = joins(:assessments).where(assessments: { completed: false, default: false })
        clients.each do |client|
          if client.eligible_custom_csi? && client.assessments.customs.any?
            CaseWorkerMailer.notify_incomplete_daily_csi_assessments(client).deliver_now
          end
        end
      end
    end
  end

  def most_recent_csi_assessment
    assessments.defaults.most_recents.first.created_at.to_date
  end

  def most_recent_custom_csi_assessment
    assessments.customs.most_recents.first.created_at.to_date
  end

  def repeat_notifications_schedule(default = true)
    if default
      most_recent_csi   = most_recent_csi_assessment
    else
      most_recent_csi   = most_recent_custom_csi_assessment
    end

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

  def eligible_default_csi?
    return true if date_of_birth.nil?
    client_age = age_as_years
    age        = Setting.first.age || 18
    client_age < age ? true : false
  end

  def eligible_custom_csi?
    return true if date_of_birth.nil?
    client_age = age_as_years
    age        = Setting.first.custom_age || 18
    client_age < age ? true : false
  end

  def country_origin_label
    country_origin.present? ? country_origin : 'cambodia'
  end

  def family
    Family.where('children && ARRAY[?]', id).last
  end

  def create_or_update_shared_client
    current_org = Organization.current
    client_commune = "#{self.try(&:commune_name_kh)} / #{self.try(&:commune_name_en)}"
    client_village = "#{self.try(&:village_name_kh)} / #{self.try(&:village_name_en)}"
    client = self.slice(:given_name, :family_name, :local_given_name, :local_family_name, :gender, :date_of_birth, :telephone_number, :live_with, :slug, :archived_slug, :birth_province_id, :country_origin)
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

    name_field = "#{self.given_name} #{self.family_name} #{self.local_given_name} #{self.local_family_name}".squish
    client_birth_province = Province.find_by(id: self.birth_province_id).try(&:name)

    client[:duplicate_checker] = "#{name_field} & #{client_village} & #{client_commune} & #{self.try(&:district_name)} & #{self.try(&:province_name)} & #{client_birth_province} & #{self.try(&:date_of_birth)}"
    shared_client = SharedClient.find_by(archived_slug: client['archived_slug'])
    shared_client.present? ? shared_client.update(client) : SharedClient.create(client)
    Organization.switch_to current_org.short_name
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

  def assessment_duration(duration, default = true)
    if duration == 'max'
      setting = Setting.first
      if default
        assessment_period    = setting.max_assessment
        assessment_frequency = setting.assessment_frequency
      else
        assessment_period    = setting.max_custom_assessment
        assessment_frequency = setting.custom_assessment_frequency
      end
    else
      assessment_period = 3
      assessment_frequency = 'month'
    end
    assessment_period.send(assessment_frequency)
  end

  def mark_referral_as_saved
    referral = Referral.find_by(slug: archived_slug, saved: false)
    referral.update_attributes(client_id: id, saved: true) if referral.present?
  end

  def set_country_origin
    return if country_origin.present?
    country = Setting.first.try(:country_name)
    self.country_origin = country
  end

  def calculate_time_in_care(date_time_in_care, from_time, to_time)
    return if from_time.nil? || to_time.nil?
    to_time = to_time + date_time_in_care[:years].years unless date_time_in_care[:years].nil?
    to_time = to_time + date_time_in_care[:months].months unless date_time_in_care[:months].nil?
    to_time = to_time + date_time_in_care[:weeks].weeks unless date_time_in_care[:weeks].nil?
    to_time = to_time + date_time_in_care[:days].days unless date_time_in_care[:days].nil?
    ActionController::Base.helpers.distance_of_time_in_words_hash(from_time, to_time, :except => [:seconds, :minutes, :hours])
  end
end
