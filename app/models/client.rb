class Client < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  include EntityTypeCustomField
  include NextClientEnrollmentTracking
  include ClientConstants

  extend FriendlyId

  require 'text'

  mount_uploaders :national_id_files, FileUploader
  mount_uploaders :birth_cert_files, FileUploader
  mount_uploaders :family_book_files, FileUploader
  mount_uploaders :passport_files, FileUploader
  mount_uploaders :travel_doc_files, FileUploader
  mount_uploaders :referral_doc_files, FileUploader
  mount_uploaders :local_consent_files, FileUploader
  mount_uploaders :police_interview_files, FileUploader
  mount_uploaders :other_legal_doc_files, FileUploader

  attr_accessor :assessment_id
  attr_accessor :organization, :case_type

  friendly_id :slug, use: :slugged
  mount_uploader :profile, ImageUploader

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
  belongs_to :referee
  belongs_to :carer
  belongs_to :call

  belongs_to :concern_province, class_name: 'Province',  foreign_key: 'concern_province_id'
  belongs_to :concern_district, class_name: 'District',  foreign_key: 'concern_district_id'
  belongs_to :concern_commune,  class_name: 'Commune',  foreign_key: 'concern_commune_id'
  belongs_to :concern_village,  class_name: 'Village',  foreign_key: 'concern_village_id'
  belongs_to :global_identity,  class_name: 'GlobalIdentity', foreign_key: 'global_id', primary_key: :ulid

  has_many :hotlines, dependent: :destroy
  has_many :calls, through: :hotlines
  has_many :sponsors, dependent: :destroy
  has_many :donors, through: :sponsors
  has_many :tasks,          dependent: :nullify
  has_many :surveys,        dependent: :destroy
  has_many :agency_clients, dependent: :destroy
  has_many :progress_notes, dependent: :destroy
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
  has_many :global_identity_organizations, class_name: 'GlobalIdentityOrganization', foreign_key: 'client_id', dependent: :destroy

  has_one  :family_member
  has_one  :family, through: :family_member

  accepts_nested_attributes_for :tasks
  accepts_nested_attributes_for :family_member, allow_destroy: true

  has_many :families,       through: :cases
  has_many :cases,          dependent: :destroy
  has_many :case_notes,     dependent: :destroy
  has_many :assessments,    dependent: :destroy

  has_paper_trail

  validates :kid_id, uniqueness: { case_sensitive: false }, if: 'kid_id.present?'
  validates :user_ids, presence: true, on: :create
  validates :user_ids, presence: true, on: :update, unless: :exit_ngo?
  validates :initial_referral_date, :received_by_id, :gender, :referral_source_category_id, presence: true
  validate :address_contrain, on: [:create, :update]

  validates :gender, inclusion: { in: GENDER_OPTIONS }, allow_blank: true

  validates :current_island, inclusion: { in: BRC_BRANCHES }, allow_blank: true
  validates :island2, inclusion: { in: BRC_BRANCHES }, allow_blank: true

  validates :current_resident_own_or_rent, inclusion: { in: BRC_RESIDENT_TYPES }, allow_blank: true
  validates :resident_own_or_rent2, inclusion: { in: BRC_RESIDENT_TYPES }, allow_blank: true
  validates :global_id, presence: true
  validates_uniqueness_of :global_id, on: :create

  before_validation :assign_global_id, on: :create
  before_create :set_country_origin
  before_update :disconnect_client_user_relation, if: :exiting_ngo?
  after_create :set_slug_as_alias, :save_client_global_organization, :save_external_system_global
  after_save :create_client_history, :mark_referral_as_saved, :create_or_update_shared_client

  after_commit :remove_family_from_case_worker
  after_commit :update_related_family_member, on: :update

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
  scope :of_case_worker,                           -> (user_id) { joins(:case_worker_clients).where(case_worker_clients: { user_id: user_id }).distinct }
  scope :exited_ngo,                               ->        { where(status: 'Exited') }
  scope :non_exited_ngo,                           ->        { where.not(status: ['Exited', 'Referred']) }
  scope :active_accepted_status,                   ->        { where(status: ['Active', 'Accepted']) }
  scope :referred_external,                        -> (external_system_name)       { joins(:referrals).where("clients.referred_external = ? AND referrals.ngo_name = ?", true, external_system_name) }

  class << self
    def find_shared_client(options)
      similar_fields = []
      shared_clients = []
      return shared_clients unless ['given_name', 'family_name', 'local_family_name', 'local_given_name', 'date_of_birth', 'current_province_id', 'district_id', 'commune_id', 'village_id', 'birth_province_id'].any?{|key| options.has_key?(key) }
      current_org    = Organization.current.short_name
      Organization.switch_to 'shared'
      skip_orgs_percentage = Organization.skip_dup_checking_orgs.map {|val| "%#{val.short_name}%" }
      if skip_orgs_percentage.any?
        shared_clients = SharedClient.where.not('archived_slug ILIKE ANY ( array[?] ) AND duplicate_checker IS NOT NULL', skip_orgs_percentage).select(:duplicate_checker).pluck(:duplicate_checker)
      else
        shared_clients = SharedClient.where('duplicate_checker IS NOT NULL').select(:duplicate_checker).pluck(:duplicate_checker)
      end

      Organization.switch_to current_org
      province_name = Province.find_by(id: options[:current_province_id]).try(:name)
      district_name = District.find_by(id: options[:district_id]).try(:name)
      commune_name  = Commune.find_by(id: options[:commune_id]).try(:name)
      village_name  = Village.find_by(id: options[:village_id]).try(:name)
      birth_province_name = Province.find_by(id: options[:birth_province_id]).try(:name)
      addresses_hash = { cp: province_name, cd: district_name, cc: commune_name, cv: village_name, bp: birth_province_name }
      address_hash   = { cv: 1, cc: 2, cd: 3, cp: 4, bp: 5 }

      shared_clients.compact.bsearch do |client|
        client = client.split('&')
        input_name_field  = field_name_concatenate(options)
        client_name_field = client[0].squish
        field_name = compare_matching(input_name_field, client_name_field)
        dob        = date_of_birth_matching(options[:date_of_birth], client.last.squish)
        addresses  = mapping_address(address_hash, addresses_hash, client)
        match_percentages = [field_name, dob, *addresses]
        if match_percentages.compact.present? && (match_percentages.compact.inject(:*) * 100) >= 75
          similar_fields << '#hidden_name_fields' if match_percentages[0].present?
          similar_fields << '#hidden_date_of_birth' if match_percentages[1].present?
          similar_fields << '#hidden_province' if match_percentages[2].present?
          similar_fields << '#hidden_district' if match_percentages[3].present?
          similar_fields << '#hidden_commune' if match_percentages[4].present?
          similar_fields << '#hidden_village' if match_percentages[5].present?
          similar_fields << '#hidden_birth_province' if match_percentages[6].present?
          return similar_fields.uniq
        end
      end
      similar_fields.uniq
    end

    def check_for_duplication(options, shared_clients)
      the_address_code = options[:address_current_village_code]
      case the_address_code&.size
      when 4
        results = District.get_district_name_by_code(the_address_code)
      when 6
        results = Commune.get_commune_name_by_code(the_address_code)
      when 8
        results = Village.get_village_name_by_code(the_address_code)
      end

      birth_province_name = Province.find_by_code(options[:birth_province_code])
      address_hash = { cv: 1, cc: 2, cd: 3, cp: 4 }
      result = shared_clients.compact.bsearch do |client|
        client = client.split('&')
        input_name_field     = field_name_concatenate(options)
        client_name_field    = client[0].squish
        field_name = compare_matching(input_name_field, client_name_field)
        dob        = date_of_birth_matching(options[:date_of_birth], client.last.squish)
        addresses  = mapping_address(address_hash, results, client)
        bp         = birth_province_matching(birth_province_name, client[5].squish)
        match_percentages = [field_name, dob, *addresses, bp]
        if match_percentages.compact.present? && (match_percentages.compact.inject(:*) * 100) >= 75
          return true
        end
      end
      return false
    end

    def field_name_concatenate(options)
      "#{options[:given_name]} #{options[:family_name]} #{options[:local_family_name]} #{options[:local_given_name]}".squish
    end

    def mapping_address(address_hash, results, client)
      address_hash.map do |k, v|
        client_address_matching(results[k], client[v].squish) if results[k]
      end
    end

    def unattache_to_other_families(allowed_family_id = nil)
      records = joins("LEFT JOIN family_members ON clients.id = family_members.client_id WHERE family_members.family_id IS NULL")

      if allowed_family_id.present?
        records += joins(:family_member).where(family_members: { family_id: allowed_family_id})
      end

      records
    end

    def update_external_ids(short_name, client_ids, data_hash)
      Apartment::Tenant.switch(short_name) do
        Client.where(id: client_ids).each do |client|
          attributes = { external_id: data_hash[client.global_id].first, external_id_display: data_hash[client.global_id].last }
          client.update_columns(attributes)
        end
      end
    end
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

  def require_screening_assessment?(setting)
    setting.use_screening_assessment? &&
    referred? &&
    custom_fields.exclude?(setting.screening_assessment_form)
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

  def display_name
    ["Client ##{id}", name].select(&:present?).join(' - ')
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
    return Date.today if assessments.defaults.latest_record.blank?
    return nil if user_activated_date.present? && (assessments.defaults.latest_record.present? && assessments.defaults.latest_record.created_at < user_activated_date)
    (assessments.defaults.latest_record.created_at + assessment_duration('max')).to_date
  end

  def custom_next_assessment_date(user_activated_date = nil, custom_assessment_setting_id=nil)
    custom_assessments = []
    custom_assessments = assessments.customs.joins(:domains).where(domains: {custom_assessment_setting_id: custom_assessment_setting_id}).distinct if custom_assessment_setting_id
    if custom_assessment_setting_id && custom_assessments.present?
      return nil if user_activated_date.present? && custom_assessments.latest_record.created_at < user_activated_date
      (custom_assessments.latest_record&.created_at + assessment_duration('max', false, custom_assessment_setting_id)).to_date
    else
      Date.today
    end
  end

  def next_appointment_date
    return Date.today if assessments.count.zero?

    last_assessment  = assessments.most_recents.first
    last_case_note   = case_notes.most_recents.first
    next_appointment = [last_assessment, last_case_note].compact.sort { |a, b| b.try(:created_at) <=> a.try(:created_at) }.first

    next_appointment.created_at + 1.month
  end


  def can_create_assessment?(default, value='')
    latest_assessment = assessments.customs.joins(:domains).where(domains: {custom_assessment_setting_id: value}).distinct
    if default
      # if assessments.defaults.count == 1
      #   return (Date.today >= (assessments.defaults.latest_record.created_at + assessment_duration('min')).to_date) && assessments.defaults.latest_record.completed?
      # elsif assessments.defaults.count >= 2
      # end
      return assessments.defaults.count == 0 || assessments.defaults.latest_record.try(:completed?)
    else
      if latest_assessment.count == 1
        return (Date.today >= (latest_assessment.latest_record.created_at + assessment_duration('min', false)).to_date) && latest_assessment.latest_record.try(:completed?)
      elsif latest_assessment.count >= 2
        return latest_assessment.latest_record.try(:completed?)
      else
        return true
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

  def has_no_latest_kc_and_fc?
    !latest_case
  end

  def has_any_quarterly_reports?
    (cases.with_deleted.active.latest_kinship.present? && cases.with_deleted.latest_kinship.quarterly_reports.any?) || (cases.with_deleted.active.latest_foster.present? && cases.with_deleted.latest_foster.quarterly_reports.any?)
  end

  def latest_case
    cases.with_deleted.active.latest_kinship.presence || cases.with_deleted.active.latest_foster.presence
  end

  def age_as_years(date = Date.today)
    ((date - date_of_birth) / 365).to_i
  end

  def age_extra_months(date = Date.today)
    ((date - date_of_birth) % 365 / 31).to_i
  end

  def age
    count_year_from_date('date_of_birth')
  end

  def count_year_from_date(field_date)
    return nil if self.send(field_date).nil?
    date_today = Date.today
    year_count = distance_of_time_in_words_hash(date_today, self.send(field_date)).dig(:years)
    year_count = year_count == 0 ? 'INVALID' : year_count
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
    short_name = Apartment::Tenant.current
    if archived_slug.present?
      if slug.in? Client.pluck(:slug)
        random_char = slug.split('-')[0]
        paper_trail.without_versioning { |obj| obj.update_columns(slug: "#{random_char}-#{id}") }
      end
    else
      random_char = generate_random_char
      Organization.switch_to short_name
      paper_trail.without_versioning { |obj| obj.update_columns(slug: "#{random_char}-#{id}", archived_slug: "#{Organization.current.try(:short_name)}-#{id}") }
    end
  end

  def generate_random_char
    Organization.switch_to 'shared'
    loop do
      char = ('a'..'z').to_a.sample(4).join()
      break char unless SharedClient.find_by(slug: "#{char}-#{id}").present?
    end
  end

  def time_in_ngo
    return {} if self.status == 'Referred'
    day_time_in_ngos = calculate_day_time_in_ngo
    if day_time_in_ngos.present?
      years = day_time_in_ngos / 365
      remaining_day_from_year = day_time_in_ngos % 365

      months = remaining_day_from_year / 30
      remaining_day_from_month = remaining_day_from_year % 30
      detail_time_in_ngo = { years: years, months: months, days: remaining_day_from_month }
    end
  end

  def calculate_day_time_in_ngo
    enter_ngos = self.enter_ngos.order(created_at: :desc)
    return 0 if (enter_ngos.size.zero?)

    exit_ngos  = self.exit_ngos.order(exit_date: :desc).where("created_at >= ?", enter_ngos.last.created_at)
    enter_ngo_dates = enter_ngos.pluck(:accepted_date)
    exit_ngo_dates  = exit_ngos.pluck(:exit_date)

    exit_ngo_dates.unshift(Date.today) if exit_ngo_dates.size < enter_ngo_dates.size
    day_time_in_ngos = exit_ngo_dates.each_with_index.inject(0) do |sum, (exit_ngo_date, index)|
      enter_ngo_date = enter_ngo_dates[index]
      next_ngo_date = enter_ngo_dates[index + 1]

      if next_ngo_date != enter_ngo_date
        day_in_ngo = (exit_ngo_date - enter_ngo_date).to_i
        sum += day_in_ngo < 0 ? 0 : day_in_ngo + 1
      end
      sum
    end
    day_time_in_ngos
  end

  def brc_current_address
    [
      current_island,
      current_settlement,
      current_street,
      current_po_box,
      current_resident_own_or_rent,
      current_household_type
    ].select(&:present?).join(', ')
  end

  def brc_other_address
    [
      island2,
      settlement2,
      street2,
      po_box2,
      resident_own_or_rent2,
      household_type2
    ].select(&:present?).join(', ')
  end

  def to_select2
    [
      display_name, id, { data: {
          date_of_birth: date_of_birth,
          gender: gender
        }
      }
    ]
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
        date_time_in_cps = { years: 0, months: 0, weeks: 0, days: 0 }
        date_time_in_cps = calculate_time_in_care(date_time_in_cps, current_or_exit, enroll_date)
      else
        date_time_in_cps = { years: 0, months: 0, weeks: 0, days: 0 }
        date_time_in_cps = calculate_time_in_care(date_time_in_cps, current_or_exit, enroll_date)
      end

      if detail_cps["#{enrollment.program_stream_name}"].present?
        detail_cps["#{enrollment.program_stream_name}"][:years].present? ? detail_cps["#{enrollment.program_stream_name}"][:years] : detail_cps["#{enrollment.program_stream_name}"][:years] = 0
        detail_cps["#{enrollment.program_stream_name}"][:months].present? ? detail_cps["#{enrollment.program_stream_name}"][:months] : detail_cps["#{enrollment.program_stream_name}"][:months] = 0
        detail_cps["#{enrollment.program_stream_name}"][:days].present? ? detail_cps["#{enrollment.program_stream_name}"][:days] : detail_cps["#{enrollment.program_stream_name}"][:days] = 0

        if date_time_in_cps.present?
          detail_cps["#{enrollment.program_stream_name}"][:years] += date_time_in_cps[:years].present? ? date_time_in_cps[:years] : 0
          detail_cps["#{enrollment.program_stream_name}"][:months] += date_time_in_cps[:months].present? ? date_time_in_cps[:months] : 0
          detail_cps["#{enrollment.program_stream_name}"][:days] += date_time_in_cps[:days].present? ? date_time_in_cps[:days] : 0
        end
      else
        detail_cps["#{enrollment.program_stream_name}"] = date_time_in_cps
      end
    end

    detail_cps.values.map do |value|
      next if value.blank?
      value.store(:years, 0) unless value[:years].present?
      value.store(:months, 0) unless value[:months].present?
      value.store(:days, 0) unless value[:days].present?

      if value[:days] > 365
        value[:years] = value[:years] + value[:days]/365
        value[:days] = value[:days] % 365
      elsif value[:days] == 365
        value[:years]  = 1
        value[:days]   = 0
        value[:months] = 0
      end

      if value[:days] > 30
        value[:months] = value[:days] / 30
        value[:days] = value[:days] % 30
      elsif value[:days] == 30
        value[:days] = 0
        value[:months] = 1
      end
    end
    detail_cps
  end

  def self.exit_in_week(number_of_day)
    date = number_of_day.day.ago.to_date
    active_status.joins(:cases).where(cases: { case_type: 'EC', start_date: date, exited: false })
  end

  def exiting_ngo?
    return false unless status_changed?
    status == 'Exited'
  end

  def self.notify_upcoming_csi_assessment
    Organization.all.each do |org|
      Organization.switch_to org.short_name

      next if !(Setting.first.enable_default_assessment) && !(Setting.first.enable_custom_assessment?)
      clients = joins(:assessments).active_accepted_status

      clients.each do |client|
        if Setting.first.enable_default_assessment && client.eligible_default_csi? && client.assessments.defaults.any?
          repeat_notifications = client.assessment_notification_dates(Setting.first)

          if(repeat_notifications.include?(Date.today))
            CaseWorkerMailer.notify_upcoming_csi_weekly(client).deliver_now
          end
        end

        if Setting.first.enable_custom_assessment && client.assessments.customs.any?
          custom_assessment_setting_ids = client.assessments.customs.map{|ca| ca.domains.pluck(:custom_assessment_setting_id ) }.flatten.uniq

          CustomAssessmentSetting.where(id: custom_assessment_setting_ids).each do |custom_assessment_setting|
            repeat_notifications = client.assessment_notification_dates(custom_assessment_setting)
            if(repeat_notifications.include?(Date.today)) && client.eligible_custom_csi?(custom_assessment_setting)
              CaseWorkerMailer.notify_upcoming_csi_weekly(client).deliver_now
            end
          end
        end
      end
    end
  end

  def self.notify_incomplete_daily_csi_assessment
    Organization.all.each do |org|
      Organization.switch_to org.short_name

      setting = Setting.first_or_initialize
      next if setting.disable_required_fields?

      if Setting.first.enable_default_assessment
        clients = joins(:assessments).where(assessments: { completed: false, default: true })
        clients.each do |client|
          if client.eligible_default_csi? && client.assessments.defaults.any?
            CaseWorkerMailer.notify_incomplete_daily_csi_assessments(client).deliver_now
          end
        end
      end

      if Setting.first.enable_custom_assessment?
        clients = joins(:assessments).where(assessments: { completed: false, default: false })
        clients.each do |client|
          custom_assessment_setting_ids = client.assessments.customs.map{|ca| ca.domains.pluck(:custom_assessment_setting_id ) }.flatten.uniq
          CustomAssessmentSetting.where(id: custom_assessment_setting_ids).each do |custom_assessment_setting|
            if client.eligible_custom_csi?(custom_assessment_setting) && client.assessments.customs.any?
              CaseWorkerMailer.notify_incomplete_daily_csi_assessments(client, custom_assessment_setting).deliver_now
            end
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

  def assessment_notification_dates(setting)
    recent_assessment_date = most_recent_csi_assessment

    unless setting.instance_of?(Setting)
      recent_assessment_date = assessments.customs.most_recents.joins(:domains).where(custom_assessment_setting_id: setting.id).first.created_at.to_date
    end

    next_assessment_date = recent_assessment_date + setting.max_assessment_duration

    Setting.first.two_weeks_assessment_reminder? ? [(next_assessment_date - 2.weeks), (next_assessment_date - 1.week)] : [next_assessment_date - 1.week]
  rescue
    []
  end

  def eligible_default_csi?
    return true if date_of_birth.nil?
    client_age = age_as_years
    age        = Setting.first.age || 18
    client_age < age ? true : false
  end

  def eligible_custom_csi?(custom_assessment_setting)
    return true if date_of_birth.nil?
    client_age = age_as_years
    age        = custom_assessment_setting.custom_age || 18
    client_age < age ? true : false
  end

  def country_origin_label
    country_origin.present? ? country_origin : 'cambodia'
  end

  def create_or_update_shared_client
    current_org = Organization.current
    client_commune = "#{self.try(&:commune_name_kh)} / #{self.try(&:commune_name_en)}"
    client_village = "#{self.try(&:village_name_kh)} / #{self.try(&:village_name_en)}"
    client = self.slice(:given_name, :family_name, :local_given_name, :local_family_name, :gender, :date_of_birth, :telephone_number, :live_with, :slug, :archived_slug, :birth_province_id, :country_origin, :global_id, :external_id, :external_id_display, :mosvy_number, :external_case_worker_name, :external_case_worker_id)
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

  def self.get_client_attribute(attributes, referral_source_category_id=nil)
    attribute = attributes.with_indifferent_access
    client_attributes = {
      external_id:            attribute[:external_id],
      external_id_display:    attribute[:external_id_display],
      mosvy_number:           attribute[:mosvy_number],
      given_name:             attribute[:given_name],
      family_name:            attribute[:family_name],
      gender:                 attribute[:gender],
      date_of_birth:          attribute[:date_of_birth],
      reason_for_referral:    attribute[:referral_reason],
      relevant_referral_information:    attribute[:referral_reason],
      referral_source_category_id: ReferralSource.find_by(name: attribute[:referred_from])&.id || referral_source_category_id,
      external_case_worker_id:   attribute[:external_case_worker_id],
      external_case_worker_name: attribute[:external_case_worker_name],
      **get_address_by_code(attribute[:address_current_village_code] || attribute[:location_current_village_code] || attribute[:village_code])
    }
  end

  def self.get_address_by_code(the_address_code)
    char_size = the_address_code&.length
    case char_size
    when 4
      District.get_district(the_address_code)
    when 6
      Commune.get_commune(the_address_code)
    else
      Village.get_village(the_address_code)
    end
  end

  def indirect_beneficiaries
    result = 0
    family_id = self.family_member.try(:family_id)
    result = Family.find_by(id: family_id).family_members.where(client_id: nil).count if family_id.present?
    result > 0 ? result -1 : result
  end

  private

  def update_related_family_member
    FamilyMember.delay.update_client_relevant_data(family_member.id, Apartment::Tenant.current) if family_member.present? && family_member.persisted?
  end

  def create_client_history
    ClientHistory.initial(self)
  end

  def notify_managers
    ClientMailer.exited_notification(self, User.deleted_user.managers.non_locked.pluck(:email)).deliver_now
  end

  def disconnect_client_user_relation
    case_worker_clients.destroy_all
  end

  def remove_family_from_case_worker
    if family
      clients = Client.joins(:users).where(current_family_id: family.id, case_worker_clients: {user_id: family.user_id})
      if clients.blank?
        family.user_id = nil
        family.save
      end
    else
      case_worker_clients.each do |case_worker_client|
        case_worker_client.user.families.each do |family|
          clients = family.clients.joins(:case_worker_clients).where(case_worker_clients: { user_id: case_worker_client&.user_id }, current_family_id: family.id).exists?
          if clients.blank?
            family.user_id = nil
            family.save
          end
        end
      end
    end
  end

  def assessment_duration(duration, default = true, custom_assessment_setting_id=nil)
    if duration == 'max'
      setting = Setting.first
      if default
        assessment_period    = setting.max_assessment
        assessment_frequency = setting.assessment_frequency
      else
        if custom_assessment_setting_id
          custom_assessment_setting = CustomAssessmentSetting.find(custom_assessment_setting_id)
          assessment_period    = custom_assessment_setting.max_custom_assessment
          assessment_frequency = custom_assessment_setting.custom_assessment_frequency
        else
          assessment_period    = setting.max_custom_assessment
          assessment_frequency = setting.custom_assessment_frequency
        end
      end
    else
      assessment_period = 3
      assessment_frequency = 'month'
    end
    assessment_period.send(assessment_frequency)
  end

  def mark_referral_as_saved
    referral = find_referral
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

    from_time = from_time.to_date
    to_time = to_time.to_date
    if from_time >= to_time
      time_days = (from_time - to_time).to_i + 1
      times = {days: time_days}
    end
  end

  def address_contrain
    if district_id && province_id
      district = District.find(district_id)
      errors.add(:district_id, 'does not exist in the province you just selected.') if district.province_id != province_id
    end

    if commune_id && district_id && province_id
      commune = Commune.find(commune_id)
      errors.add(:commune_id, 'does not exist in the district you just selected.') if commune.district_id != district_id
    end

    if village_id && commune_id && district_id && province_id
      vaillage = Village.find(village_id)
      errors.add(:village_id, 'does not exist in the commune you just selected.') if village.commune_id != commune_id
    end
  end

  def assign_global_id
    if global_id.blank?
      referral = find_referral
      self.global_id = referral ? referral.client_global_id : GlobalIdentity.create(ulid: ULID.generate).ulid
    end
  end

  def save_client_global_organization
    GlobalIdentityOrganization.find_or_create_by(global_id: global_id, organization_id: Organization.current&.id, client_id: id)
  end

  def save_external_system_global
    if persisted? && external_id.present?
      external_system_global = global_identity.external_system_global_identities.find_by(external_id: external_id)
      external_system_global && external_system_global.update_attributes(client_slug: slug)
    end
  end

  def find_referral
    referral = nil
    if external_id.present?
      referral = Referral.find_by(external_id: external_id, saved: false)
    else
      referral = Referral.find_by(slug: archived_slug, saved: false) if archived_slug.present?
    end
  end

  def remove_tasks(case_worker)
    if case_worker.tasks.incomplete.exists?
      case_worker.tasks.incomplete.destroy_all
    end
  end
end
