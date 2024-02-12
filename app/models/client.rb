class Client < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  include EntityTypeCustomField
  include NextClientEnrollmentTracking
  include ClientConstants
  include CsiConcern

  extend FriendlyId

  acts_as_paranoid

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
  mount_uploaders :ngo_partner_files, FileUploader
  mount_uploaders :mosavy_files, FileUploader
  mount_uploaders :dosavy_files, FileUploader
  mount_uploaders :msdhs_files, FileUploader
  mount_uploaders :complain_files, FileUploader
  mount_uploaders :warrant_files, FileUploader
  mount_uploaders :verdict_files, FileUploader
  mount_uploaders :short_form_of_ocdm_files, FileUploader
  mount_uploaders :screening_interview_form_files, FileUploader
  mount_uploaders :short_form_of_mosavy_dosavy_files, FileUploader
  mount_uploaders :detail_form_of_mosavy_dosavy_files, FileUploader
  mount_uploaders :short_form_of_judicial_police_files, FileUploader
  mount_uploaders :detail_form_of_judicial_police_files, FileUploader
  mount_uploaders :letter_from_immigration_police_files, FileUploader

  attr_accessor :assessment_id, :ngo_name
  attr_accessor :organization, :case_type

  friendly_id :slug, use: :slugged
  mount_uploader :profile, ImageUploader

  delegate :name, to: :referral_source, prefix: true, allow_nil: true
  delegate :name, to: :township, prefix: true, allow_nil: true
  delegate :name, to: :province, prefix: true, allow_nil: true
  delegate :name, to: :birth_province, prefix: true, allow_nil: true
  delegate :name, to: :city, prefix: true, allow_nil: true
  delegate :name, to: :district, prefix: true, allow_nil: true
  delegate :name, to: :subdistrict, prefix: true, allow_nil: true
  delegate :name, to: :state, prefix: true, allow_nil: true
  delegate :name_kh, to: :commune, prefix: true, allow_nil: true
  delegate :name_kh, to: :village, prefix: true, allow_nil: true
  delegate :name_en, to: :commune, prefix: true, allow_nil: true
  delegate :name_en, to: :village, prefix: true, allow_nil: true

  belongs_to :referral_source, counter_cache: true
  belongs_to :province, counter_cache: true
  belongs_to :city
  belongs_to :district
  belongs_to :subdistrict
  belongs_to :township
  belongs_to :state
  belongs_to :received_by, class_name: 'User', foreign_key: 'received_by_id', counter_cache: true
  belongs_to :followed_up_by, class_name: 'User', foreign_key: 'followed_up_by_id', counter_cache: true
  belongs_to :birth_province, class_name: 'Province', foreign_key: 'birth_province_id', counter_cache: true
  belongs_to :commune
  belongs_to :village
  belongs_to :referee
  belongs_to :carer
  belongs_to :archived_by, class_name: 'User'

  belongs_to :concern_province, class_name: 'Province', foreign_key: 'concern_province_id'
  belongs_to :concern_district, class_name: 'District', foreign_key: 'concern_district_id'
  belongs_to :concern_commune, class_name: 'Commune', foreign_key: 'concern_commune_id'
  belongs_to :concern_village, class_name: 'Village', foreign_key: 'concern_village_id'
  belongs_to :global_identity, class_name: 'GlobalIdentity', foreign_key: 'global_id', primary_key: :ulid

  has_many :hotlines, dependent: :destroy
  has_many :calls, through: :hotlines
  has_many :sponsors, dependent: :destroy
  has_many :donors, through: :sponsors
  has_many :tasks, dependent: :nullify
  has_many :surveys, dependent: :destroy
  has_many :agency_clients, dependent: :destroy
  has_many :progress_notes, dependent: :destroy
  has_many :agencies, through: :agency_clients
  has_many :shared_clients, foreign_key: :slug, primary_key: :slug

  has_many :client_quantitative_free_text_cases, dependent: :destroy
  has_many :client_quantitative_cases, dependent: :destroy
  has_many :quantitative_cases, through: :client_quantitative_cases

  has_many :custom_field_properties, as: :custom_formable, dependent: :destroy
  has_many :custom_fields, through: :custom_field_properties, as: :custom_formable
  has_many :client_enrollments, dependent: :destroy
  has_many :program_streams, through: :client_enrollments
  has_many :case_worker_clients, dependent: :destroy
  has_many :users, through: :case_worker_clients, validate: false
  has_many :enter_ngos, dependent: :destroy
  has_many :exit_ngos, as: :rejectable, dependent: :destroy
  has_many :referrals, dependent: :destroy
  has_many :government_forms, dependent: :destroy
  has_many :global_identity_organizations, class_name: 'GlobalIdentityOrganization', foreign_key: 'client_id', dependent: :destroy
  has_many :mo_savy_officials, dependent: :destroy
  has_many :achievement_program_staff_clients, dependent: :destroy
  has_many :ratanak_achievement_program_staff_clients, through: :achievement_program_staff_clients, source: :user

  has_one :risk_assessment, dependent: :destroy
  has_one :family_member, dependent: :restrict_with_error
  has_one :family, through: :family_member
  has_one :client_custom_data, dependent: :destroy
  has_one :custom_data, through: :client_custom_data

  accepts_nested_attributes_for :tasks
  accepts_nested_attributes_for :client_quantitative_free_text_cases
  accepts_nested_attributes_for :achievement_program_staff_clients
  accepts_nested_attributes_for :family_member, allow_destroy: true
  accepts_nested_attributes_for :mo_savy_officials, allow_destroy: true, reject_if: :all_blank

  has_many :families, through: :cases
  has_many :family_members, dependent: :destroy
  has_many :cases, dependent: :destroy
  has_many :case_notes, dependent: :destroy
  has_many :assessments, dependent: :destroy
  has_many :default_most_recents_assessments, -> { defaults.most_recents }, class_name: 'Assessment'
  has_many :custom_assessments, -> { customs }, class_name: 'Assessment'
  has_many :custom_assessment_domains, through: :custom_assessments, source: :domains

  has_many :care_plans, dependent: :destroy
  has_many :goals, dependent: :destroy
  has_many :case_conferences, dependent: :destroy
  has_many :internal_referrals, dependent: :destroy
  has_many :screening_assessments, dependent: :destroy

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
  after_validation :save_client_global_organization, on: :create
  before_create :set_country_origin
  after_create :set_slug_as_alias, :mark_referral_as_saved
  after_save :create_client_history, :create_or_update_shared_client
  after_commit :do_duplicate_checking

  # save_global_identify_and_external_system_global_identities must be executed first
  after_commit :save_global_identify_and_external_system_global_identities, on: :create
  after_commit :remove_family_from_case_worker
  after_commit :update_related_family_member, on: :update
  after_commit :delete_referee, on: :destroy
  after_save :update_referral_status_on_target_ngo, if: :status_changed?
  after_save :flash_cache
  after_commit :update_first_referral_status, on: :update

  scope :given_name_like, -> (value) { where('clients.given_name iLIKE :value OR clients.local_given_name iLIKE :value', { value: "%#{value.squish}%" }) }
  scope :family_name_like, -> (value) { where('clients.family_name iLIKE :value OR clients.local_family_name iLIKE :value', { value: "%#{value.squish}%" }) }
  scope :local_given_name_like, -> (value) { where('clients.local_given_name iLIKE ?', "%#{value.squish}%") }
  scope :local_family_name_like, -> (value) { where('clients.local_family_name iLIKE ?', "%#{value.squish}%") }
  scope :slug_like, -> (value) { where('clients.slug iLIKE ?', "%#{value.squish}%") }
  scope :start_with_code, -> (value) { where('clients.code iLIKE ?', "#{value}%") }
  scope :find_by_family_id, -> (value) { joins(cases: :family).where('families.id = ?', value).uniq }
  scope :status_like, -> { CLIENT_STATUSES }
  scope :is_received_by, -> { joins(:received_by).pluck("CONCAT(users.first_name, ' ' , users.last_name)", 'users.id').uniq }
  scope :referral_source_is, -> { joins(:referral_source).where.not('referral_sources.name in (?)', ReferralSource::REFERRAL_SOURCES).pluck('referral_sources.name', 'referral_sources.id').uniq }
  scope :is_followed_up_by, -> { joins(:followed_up_by).pluck("CONCAT(users.first_name, ' ' , users.last_name)", 'users.id').uniq }
  scope :province_is, -> { joins(:province).pluck('provinces.name', 'provinces.id').uniq }
  scope :birth_province_is, -> { joins(:birth_province).pluck('provinces.name', 'provinces.id').uniq }
  scope :accepted, -> { where(status: 'Accepted') }
  scope :rejected, -> { where(state: 'rejected') }
  scope :male, -> { where(gender: 'male') }
  scope :female, -> { where(gender: 'female') }
  scope :active_ec, -> { where(status: 'Active EC') }
  scope :active_kc, -> { where(status: 'Active KC') }
  scope :active_fc, -> { where(status: 'Active FC') }
  scope :without_assessments, -> { includes(:assessments).where(assessments: { client_id: nil }) }
  scope :active_status, -> { where(status: 'Active') }
  scope :of_case_worker, -> (user_id) { joins(:case_worker_clients).where(case_worker_clients: { user_id: user_id }).distinct }
  scope :exited_ngo, -> { where(status: 'Exited') }
  scope :non_exited_ngo, -> { where.not(status: ['Exited', 'Referred']) }
  scope :active_accepted_status, -> { where(status: ['Active', 'Accepted']) }
  scope :active_accepted_referred_status, -> { where(status: ['Active', 'Accepted', 'Referred']) }
  scope :referred_external, -> (external_system_name) { joins(:referrals).where('clients.referred_external = ? AND referrals.ngo_name = ?', true, external_system_name) }
  scope :test_clients, -> { where(for_testing: true) }
  scope :without_test_clients, -> { where(for_testing: false) }
  scope :reportable, -> { with_deleted.without_test_clients }

  scope :male_shared_clients, -> { joins(:shared_clients).where('shared.shared_clients.gender = ?', 'male') }
  scope :female_shared_clients, -> { joins(:shared_clients).where('shared.shared_clients.gender = ?', 'female') }
  scope :non_binary_shared_clients, -> { joins(:shared_clients).where('shared.shared_clients.gender NOT IN (?)', %w(male female)) }
  scope :adult, -> { where('(EXTRACT(year FROM age(current_date, clients.date_of_birth)) :: int) >= ?', 18) }
  scope :child, -> { where('(EXTRACT(year FROM age(current_date, clients.date_of_birth)) :: int) < ?', 18) }
  scope :no_school, -> { where(school_grade: [nil, '']) }
  scope :pre_school, -> { where(school_grade: ['Kindergarten 1', 'Kindergarten 2', 'Kindergarten 3', 'Kindergarten 4']) }
  scope :primary_school, -> { where(school_grade: ['1', '2', '3', '4', '5', '6']) }
  scope :secondary_school, -> { where(school_grade: ['7', '8', '9']) }
  scope :high_school, -> { where(school_grade: ['10', '11', '12']) }
  scope :university, -> { where(school_grade: ['Year 1', 'Year 2', 'Year 3', 'Year 4', 'Year 5', 'Year 6', 'Year 7', 'Year 8', 'Bachelors']) }

  class << self
    def find_shared_client(options)
      shared_client = nil

      if options[:slug]
        client = Client.find_by(slug: options[:slug])
        shared_client = client.shared_clients.last if client.present?
      end

      similar_fields = []
      shared_clients = []

      if (Client::DUPLICATE_CHECKING_FIELDS.map(&:to_s) & options.keys.map(&:to_s)).blank? || shared_client&.resolved_duplication_by.present?
        return { similar_fields: similar_fields, duplicate_with: nil }
      end

      current_org = Organization.current.short_name

      Apartment::Tenant.switch 'shared' do
        skip_orgs_percentage = Organization.skip_dup_checking_orgs.map { |val| "%#{val.short_name}%" }

        if skip_orgs_percentage.any?
          shared_clients = SharedClient.where.not(slug: options[:slug]).where.not('archived_slug ILIKE ANY ( array[?] ) AND duplicate_checker IS NOT NULL', skip_orgs_percentage)
        else
          shared_clients = SharedClient.where.not(slug: options[:slug]).where('duplicate_checker IS NOT NULL')
        end
      end

      province_name = Province.find_by(id: options[:current_province_id]).try(:name)
      district_name = District.find_by(id: options[:district_id]).try(:name)
      commune_name = Commune.find_by(id: options[:commune_id]).try(:name)
      village_name = Village.find_by(id: options[:village_id]).try(:name)

      birth_province_name = Apartment::Tenant.switch 'shared' do
        Province.find_by(id: options[:birth_province_id]).try(:name)
      end

      addresses_hash = { cp: province_name, cd: district_name, cc: commune_name, cv: village_name, bp: birth_province_name }
      address_hash = { cv: 1, cc: 2, cd: 3, cp: 4, bp: 5 }

      shared_clients.each do |client|
        next if client.duplicate_checker.blank?

        duplicate_checker_data = client.duplicate_checker.split('&')
        input_name_field = field_name_concatenate(options)
        client_name_field = duplicate_checker_data[0].squish
        field_name = compare_matching(input_name_field, client_name_field)
        dob = date_of_birth_matching(options[:date_of_birth], duplicate_checker_data.last.squish)
        addresses = mapping_address(address_hash, addresses_hash, duplicate_checker_data)
        gender_matching = options[:gender].to_s.downcase == duplicate_checker_data[7].to_s.downcase ? 1 : nil
        match_percentages = [field_name, dob, *addresses, gender_matching]

        percentages = match_percentages.compact

        if percentages.any? && (match_percentages.compact.inject(:*) * 100) >= 75
          Rails.logger.info "Found similar client with percentage: #{(match_percentages.compact.inject(:*) * 100)} - #{match_percentages} - #{addresses_hash} - #{duplicate_checker_data}"

          similar_fields << '#hidden_name_fields' if match_percentages[0].present?
          similar_fields << '#hidden_date_of_birth' if match_percentages[1].present?
          similar_fields << '#hidden_village' if match_percentages[2].present?
          similar_fields << '#hidden_commune' if match_percentages[3].present?
          similar_fields << '#hidden_district' if match_percentages[4].present?
          similar_fields << '#hidden_province' if match_percentages[5].present?
          similar_fields << '#hidden_birth_province' if match_percentages[6].present?
          similar_fields << '#hidden_gender' if match_percentages[7].present?

          return { similar_fields: similar_fields, duplicate_with: client.archived_slug }
        end
      end

      { similar_fields: similar_fields, duplicate_with: nil }
    end

    def check_for_duplication(options, shared_clients)
      the_address_code = options[:address_current_village_code]
      case the_address_code&.size
      when 2
        results = Province.map_name_by_code(the_address_code)
      when 4
        results = District.get_district_name_by_code(the_address_code)
      when 6
        results = Commune.get_commune_name_by_code(the_address_code)
      when 8
        results = Village.get_village_name_by_code(the_address_code)
      end

      birth_province_name = Province.find_name_by_code(options[:birth_province_code])
      address_hash = { cv: 1, cc: 2, cd: 3, cp: 4 }
      result = shared_clients.compact.each do |client|
        client = client.split('&')
        input_name_field = field_name_concatenate(options)
        client_name_field = client[0].squish
        field_name = compare_matching(input_name_field, client_name_field)

        dob = date_of_birth_matching(options[:date_of_birth], client.last.squish)
        addresses = mapping_address(address_hash, results, client)
        bp = birth_province_matching(birth_province_name, client[5].squish)
        match_percentages = [field_name, dob, *addresses, bp]
        if match_percentages.compact.present? && (match_percentages.compact.inject(:*) * 100) >= 75
          return true
        end
      end
      return false
    end

    def field_name_concatenate(options)
      "#{options[:given_name]} #{options[:family_name]} #{options[:local_given_name]} #{options[:local_family_name]}".squish
    end

    def mapping_address(address_hash, results = {}, client)
      address_hash.map do |k, v|
        client_address_matching(results[k], client[v].squish) if results[k]
      end
    end

    def unattache_to_other_families(allowed_family_id = nil)
      # Rails is fail to build correct query with acts_as_paranoid in this case
      records = with_deleted.joins('LEFT JOIN family_members ON clients.id = family_members.client_id WHERE family_members.family_id IS NULL AND clients.deleted_at IS NULL')

      if allowed_family_id.present?
        records += joins(:family_member).where(family_members: { family_id: allowed_family_id })
      end

      records
    end

    def update_external_ids(short_name, client_ids, data_hash)
      Apartment::Tenant.switch(short_name) do
        Client.where(id: client_ids).each do |client|
          attributes = { external_id: data_hash[client.global_id].first, external_id_display: data_hash[client.global_id].last }
          client.update_columns(attributes.merge({ synced_date: Date.today }))
        end
      end
    end

    def cache_location_of_concern
      Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'location_of_concern']) do
        Client.where.not(location_of_concern: [nil, '']).pluck(:location_of_concern).map { |a| { a => a } }
      end
    end
  end

  def self.fetch_75_chars_of(value)
    number_of_char = (value.length * 75) / 100
    value[0..(number_of_char - 1)]
  end

  def self.client_address_matching(value1, value2)
    return nil if value1.blank?
    value1 == value2 ? 1 : nil
  end

  def self.birth_province_matching(value1, value2)
    return nil if value1.blank?
    value1 == value2 ? 1 : nil
  end

  def self.compare_matching(value1, value2)
    return nil if value1.blank?
    white = Text::WhiteSimilarity.new
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
      percentage = 1 - (remain_day * 0.5) / 100 if remain_day.present?
    end

    percentage < 0 ? nil : percentage
  end

  # options[:custom]
  # options[:custom_assessment_setting_id]
  def find_or_create_draft_case_note(options = {})
    case_note = case_notes.draft_untouch.where(options).last
    case_note ||= case_notes.new(options.merge(draft: true))

    if case_note.assessment.blank?
      unless case_note.custom?
        case_note.assessment = assessments.default_latest_record
      else
        case_note.assessment = assessments.custom_latest_record if Setting.cache_first.enable_default_assessment?
      end
    end

    case_note.save(validate: false)
    case_note
  end

  # options[:default]
  # options[:case_conference_id]
  # options[:custom_assessment_setting_id]
  def find_or_create_assessment(options = {})
    assessment = assessments.draft_untouch.where(options).last
    assessment ||= assessments.new(options.merge(draft: true))
    assessment.save(validate: false)
    assessment
  end

  def accepted?
    status == 'Accepted'
  end

  def exit_ngo?
    status == 'Exited'
  end

  def latest_exit_ngo
    exit_ngos.most_recents.first
  end

  def referred?
    status == 'Referred'
  end

  def active?
    status == 'Active'
  end

  def cached_user_ids
    Rails.cache.fetch([Apartment::Tenant.current, id, 'user_ids']) do
      users.map(&:id)
    end
  end

  def require_screening_assessment?(setting)
    setting.use_screening_assessment? &&
    referred? &&
    custom_fields.exclude?(setting.screening_assessment_form) &&
    setting.screening_assessment_form.try(:entity_type) == 'Client'
  end

  def self.age_between(min_age, max_age)
    min = (min_age * 12).to_i.months.ago.to_date
    max = (max_age * 12).to_i.months.ago.to_date
    where(date_of_birth: max..min)
  end

  def name
    name = "#{given_name} #{family_name}"
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

  def en_and_local_name_with_id
    "#{en_and_local_name} (#{id})"
  end

  def next_appointment_date
    return Date.today if assessments.count.zero?

    last_assessment = assessments.most_recents.first
    last_case_note = case_notes.most_recents.first
    next_appointment = [last_assessment, last_case_note].compact.sort { |a, b| b.try(:created_at) <=> a.try(:created_at) }.first

    next_appointment.created_at + 1.month
  end

  def next_case_note_date(user_activated_date = nil)
    return Date.today if case_notes.count.zero? || case_notes.latest_record.try(:meeting_date).nil?

    return nil if user_activated_date.present? && case_notes.latest_record.created_at < user_activated_date

    setting = current_setting
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

    exit_ngos = self.exit_ngos.order(exit_date: :desc).where('created_at >= ?', enter_ngos.last.created_at)
    enter_ngo_dates = enter_ngos.pluck(:accepted_date)
    exit_ngo_dates = exit_ngos.pluck(:exit_date)

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
      } }
    ]
  end

  def time_in_cps
    date_time_in_cps = { years: 0, months: 0, weeks: 0, days: 0 }
    return nil unless client_enrollments.present?
    enrollments = client_enrollments.order(:program_stream_id)
    detail_cps = {}

    enrollments.each_with_index do |enrollment, index|
      enroll_date = enrollment.enrollment_date
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
        value[:years] = value[:years] + value[:days] / 365
        value[:days] = value[:days] % 365
      elsif value[:days] == 365
        value[:years] = 1
        value[:days] = 0
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
    obj = self.new
    Organization.oscar.without_shared.each do |org|
      Organization.switch_to org.short_name
      current_setting = Setting.first_or_initialize
      next if !(current_setting.enable_default_assessment) && !(current_setting.enable_custom_assessment?)

      clients = obj.active_young_clients(self)
      default_clients = obj.clients_have_recent_default_assessments(clients)
      custom_assessment_clients = obj.clients_have_recent_custom_assessments(clients)

      (default_clients + custom_assessment_clients).each do |client|
        CaseWorkerMailer.notify_upcoming_csi_weekly(client).deliver_now
      end
    end
  end

  def self.notify_incomplete_daily_csi_assessment
    Organization.oscar.without_shared.each do |org|
      Organization.switch_to org.short_name

      setting = Setting.first_or_initialize
      next if setting.disable_required_fields? || setting.never_delete_incomplete_assessment?

      if setting.enable_default_assessment
        clients = joins(:assessments).where(assessments: { completed: false, default: true }).where('(EXTRACT(year FROM age(current_date, coalesce(clients.date_of_birth, current_date))) :: int) < ?', setting.age || 18)
        clients.each do |client|
          CaseWorkerMailer.notify_incomplete_daily_csi_assessments(client).deliver_now
        end
      end

      next unless setting.enable_custom_assessment?

      clients = joins(:assessments).where(assessments: { completed: false, default: false }).where('(EXTRACT(year FROM age(current_date, coalesce(clients.date_of_birth, current_date))) :: int) < ?', setting.age || 18)
      clients.each do |client|
        custom_assessment_setting_ids = client.assessments.customs.map { |ca| ca.domains.pluck(:custom_assessment_setting_id) }.flatten.uniq
        CustomAssessmentSetting.where(id: custom_assessment_setting_ids).each do |custom_assessment_setting|
          CaseWorkerMailer.notify_incomplete_daily_csi_assessments(client, custom_assessment_setting).deliver_now
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
    if setting.instance_of?(CustomAssessmentSetting)
      recent_assessment_date = most_recent_custom_csi_assessment
      recent_assessment_date = assessments.customs.most_recents.joins(:domains).where(domains: { custom_assessment_setting_id: setting.id }).first.created_at.to_date
    else
      recent_assessment_date = most_recent_csi_assessment
    end

    next_assessment_date = recent_assessment_date + setting.max_assessment_duration

    current_setting.two_weeks_assessment_reminder? ? [(next_assessment_date - 2.weeks), (next_assessment_date - 1.week)] : [next_assessment_date - 1.week]
  rescue
    []
  end

  def country_origin_label
    country_origin.present? ? country_origin : 'cambodia'
  end

  def create_or_update_shared_client(client_id = nil)
    return if deleted_at? || destroyed?

    current_org = Organization.current
    client_current_province = province_name
    client_district = district_name
    client_commune = "#{self.try(&:commune_name_kh)} / #{self.try(&:commune_name_en)}"
    client_village = "#{self.try(&:village_name_kh)} / #{self.try(&:village_name_en)}"
    client = self.slice(:given_name, :family_name, :local_given_name, :local_family_name, :gender, :date_of_birth, :telephone_number, :live_with, :slug, :archived_slug, :birth_province_id, :country_origin, :global_id, :external_id, :external_id_display, :mosvy_number, :external_case_worker_name, :external_case_worker_id)
    suburb = self.suburb
    state_name = self.state_name

    client['ngo_name'] = current_org.full_name
    client['client_created_at'] = self.created_at

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

    client[:duplicate_checker] = "#{name_field} & #{client_village} & #{client_commune} & #{client_district} & #{client_current_province} & #{client_birth_province} & #{self.gender} & #{self.try(&:date_of_birth)}"
    shared_client = SharedClient.find_by(archived_slug: client['archived_slug'])
    shared_client.present? ? shared_client.update(client) : SharedClient.create(client)
    Organization.switch_to current_org.short_name
  end

  def self.get_client_attribute(attributes, referral_source_category_id = nil)
    attribute = attributes.with_indifferent_access
    referral_source_category_id = ReferralSource.find_referral_source_category(referral_source_category_id, attributes['referred_from']).try(:id)
    client_attributes = {
      mosvy_number: attribute[:mosvy_number],
      given_name: attribute[:given_name],
      family_name: attribute[:family_name],
      local_given_name: attribute[:local_given_name],
      local_family_name: attribute[:local_family_name],
      gender: attribute[:gender],
      date_of_birth: attribute[:date_of_birth],
      reason_for_referral: attribute[:referral_reason],
      relevant_referral_information: attribute[:referral_reason],
      referral_source_category_id: referral_source_category_id,
      global_id: attribute[:client_global_id],
      external_case_worker_id: attribute[:external_case_worker_id],
      external_case_worker_name: attribute[:external_case_worker_name],
      **get_address_by_code(attribute[:address_current_village_code] || attribute[:location_current_village_code] || attribute[:village_code])
    }

    client_attributes = client_attributes.merge({ external_id: attribute[:external_id], external_id_display: attribute[:external_id_display], synced_date: Date.today }) if attribute[:external_id].present?
    client_attributes
  end

  def self.get_address_by_code(the_address_code = '')
    return { village_id: nil, commune_id: nil, district_id: nil, province_id: nil } if the_address_code.blank?

    char_size = the_address_code.length
    case char_size
    when 0..2
      Province.address_by_code(the_address_code.rjust(2, '0'))
    when 3..4
      District.get_district(the_address_code.rjust(4, '0'))
    when 5..6
      Commune.get_commune(the_address_code.rjust(6, '0'))
    else
      Village.get_village(the_address_code.rjust(8, '0'))
    end
  end

  def indirect_beneficiaries
    family_member.blank? ? 0 : FamilyMember.joins(:family).where(families: { id: family_member.family_id }).where.not(client_id: nil).count
  end

  def one_off_screening_assessment
    screening_assessments.find_by(screening_type: 'one_off')
  end

  def risk_assessments
    assessments.client_risk_assessments
  end

  def last_risk_assessment
    assessments.client_risk_assessments.last
  end

  def self.cached_client_created_by(object)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_created_by', object.id]) do
      user_id = PaperTrail::Version.find_by(event: 'create', item_type: 'Client', item_id: object.id).try(:whodunnit)
      User.find_by(id: user_id || object.user_id).try(:name) || ''
    end
  end

  def self.cached_client_province_name(object)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_province_name', object.id]) do
      object.joins(:province).order('provinces.name')
    end
  end

  def self.cached_client_district_name(object)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_district_name', object.id]) do
      object.joins(:district).order('districts.name')
    end
  end

  def self.cached_client_commune_name_kh(object)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_commune_name_kh', object.id]) do
      object.joins(:commune).order('communes.name_kh')
    end
  end

  def self.cached_client_village_name_kh(object)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_village_name_kh', object.id]) do
      object.joins(:village).order('villages.name_kh')
    end
  end

  def self.cached_client_referral_source_name(object)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_referral_source_name', object.id]) do
      object.joins(:referral_source).order('referral_sources.name')
    end
  end

  def self.cached_client_assessment_number_completed_date(object, sql, assessment_number)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_assessment_number_completed_date', object.id]) do
      object.assessments.defaults.where(sql).limit(1).offset(assessment_number - 1).order('completed_date')
    end
  end

  def self.cached_client_sql_assessment_completed_date(object, sql)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_sql_assessment_completed_date', object.id]) do
      object.assessments.defaults.completed.where(sql).order('completed_date')
    end
  end

  def self.cached_client_assessment_order_completed_date(object)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_assessment_order_completed_date', object.id]) do
      object.assessments.defaults.order('completed_date')
    end
  end

  def self.cached_client_assessment_custom_number_completed_date(object, sql, assessment_number)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_assessment_custom_number_completed_date', object.id]) do
      object.assessments.customs.where(sql).limit(1).offset(assessment_number - 1).order('completed_date')
    end
  end

  def self.cached_client_sql_assessment_custom_completed_date(object, sql)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_sql_assessment_custom_completed_date', object.id]) do
      object.assessments.customs.completed.where(sql).order('completed_date')
    end
  end

  def self.cached_client_assessment_custom_order_completed_date(object)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_assessment_custom_order_completed_date', object.id]) do
      object.assessments.customs.order('completed_date')
    end
  end

  def self.cached_client_assessment_domains(value, domain_id, scope)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_assessment_domains', domain_id]) do
      ids = Assessment.joins(:assessment_domains).where("score#{operation} ? AND domain_id= ?", value, domain_id).ids
      scope.joins(:assessments).where(assessments: { id: ids })
    end
  end

  def assign_global_id
    referral = find_referrals.last
    if referral && referral.client_global_id
      self.global_id = GlobalIdentity.find_or_initialize_ulid(referral.client_global_id)
    else
      self.global_id = GlobalIdentity.new(ulid: ULID.generate).ulid
    end
  end

  def self.cache_given_name(object)
    Rails.cache.fetch([Apartment::Tenant.current, object.id, object.given_name || 'given_name']) do
      current_org = Organization.current
      Organization.switch_to 'shared'
      given_name = SharedClient.find_by(slug: object.slug)&.given_name
      Organization.switch_to current_org.short_name
      given_name
    end
  end

  def self.cache_family_name(object)
    Rails.cache.fetch([Apartment::Tenant.current, object.id, object.family_name || 'family_name']) do
      current_org = Organization.current
      Organization.switch_to 'shared'
      family_name = SharedClient.find_by(slug: object.slug)&.family_name
      Organization.switch_to current_org.short_name
      family_name
    end
  end

  def self.cache_given_name_export(object)
    Rails.cache.fetch([Apartment::Tenant.current, object.id, object.given_name || 'given_name', 'export_excel']) do
      current_org = Organization.current
      Organization.switch_to 'shared'
      given_name = SharedClient.find_by(slug: object.slug)&.given_name
      Organization.switch_to current_org.short_name
      given_name
    end
  end

  def self.cache_local_given_name(object)
    Rails.cache.fetch([Apartment::Tenant.current, object.id, object.local_given_name || 'local_given_name']) do
      current_org = Organization.current
      Organization.switch_to 'shared'
      local_given_name = SharedClient.find_by(slug: object.slug)&.local_given_name
      Organization.switch_to current_org.short_name
      local_given_name
    end
  end

  def self.cache_local_family_name(object)
    Rails.cache.fetch([Apartment::Tenant.current, object.id, object.local_family_name || 'local_family_name']) do
      current_org = Organization.current
      Organization.switch_to 'shared'
      local_family_name = SharedClient.find_by(slug: object.slug)&.local_family_name
      Organization.switch_to current_org.short_name
      local_family_name
    end
  end

  def self.cache_gender(object)
    Rails.cache.fetch([I18n.locale, Apartment::Tenant.current, object.id, object.gender || 'gender']) do
      Apartment::Tenant.switch('shared') do
        gender = SharedClient.find_by(slug: object.slug)&.gender
        gender.present? ? I18n.t("default_client_fields.gender_list.#{gender.gsub('other', 'other_gender')}") : ''
      end
    end
  end

  def is_referable_to_external_system?
    (local_given_name.blank? || local_family_name.blank? || given_name.blank? || family_name.blank?) ||
      date_of_birth.blank? || gender.blank? || province_id.blank?
  end

  def self.cached_client_custom_field_properties_count(object, fields_second)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_custom_field_properties_count', object.id, *fields_second]) do
      object.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields_second, entity_type: 'Client' }).count
    end
  end

  def self.cached_client_custom_field_properties_order(object, fields_second)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_custom_field_properties_order', object.id, *fields_second]) do
      object.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields_second, entity_type: 'Client' }).order(created_at: :desc).first.try(:properties)
    end
  end

  def self.cached_client_custom_field_find_by(object, fields_second)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_custom_field_find_by', object.id, *fields_second]) do
      object.custom_fields.find_by(form_title: fields_second)&.id
    end
  end

  def self.cached_client_custom_field_properties_properties_by(object, custom_field_id, sql, format_field_value)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_custom_field_properties_properties_by', object.id, custom_field_id]) do
      object.custom_field_properties.where(custom_field_id: custom_field_id).where(sql).properties_by(format_field_value)
    end
  end

  def self.cached_client_order_enrollment_date(object, fields_second)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_order_enrollment_date', object.id, *fields_second]) do
      date_format(object.client_enrollments.joins(:program_stream).where(program_streams: { name: fields_second }).order(enrollment_date: :desc).first.try(:enrollment_date))
    end
  end

  def self.cached_client_enrollment_date_join(object, fields_second)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_enrollment_date_join', object.id, *fields_second]) do
      date_filter(object.client_enrollments.joins(:program_stream).where(program_streams: { name: fields_second }), fields.join('__')).map { |date| date_format(date.enrollment_date) }
    end
  end

  def self.cached_client_order_enrollment_date_properties(object, fields_second)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_order_enrollment_date_properties', object.id, *fields_second]) do
      object.client_enrollments.joins(:program_stream).where(program_streams: { name: fields_second }).order(enrollment_date: :desc).first.try(:properties)
    end
  end

  def self.cached_client_enrollment_properties_by(object, fields_second, format_field_value)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', 'cached_client_enrollment_properties_by', object.id, *fields_second]) do
      object.client_enrollments.joins(:program_stream).where(program_streams: { name: fields_second }).properties_by(format_field_value)
    end
  end

  def child?
    date_of_birth.present? && date_of_birth > 18.years.ago
  end

  def adult?
    date_of_birth.present? && date_of_birth <= 18.years.ago
  end

  def male?
    gender == 'male'
  end

  def female?
    gender == 'female'
  end

  def adult_male?
    adult? && male?
  end

  def adult_female?
    adult? && female?
  end

  def child_male?
    child? && male?
  end

  def child_female?
    child? && female?
  end

  def other_gender?
    !male? && !female?
  end

  def no_school?
    school_grade.blank?
  end

  def pre_school?
    school_grade.to_s.in? ['Kindergarten 1', 'Kindergarten 2', 'Kindergarten 3', 'Kindergarten 4']
  end

  def primary_school?
    school_grade.to_s.in? ['1', '2', '3', '4', '5', '6']
  end

  def secondary_school?
    school_grade.to_s.in? ['7', '8', '9']
  end

  def high_school?
    school_grade.to_s.in? ['10', '11', '12']
  end

  def university?
    school_grade.to_s.in? ['Year 1', 'Year 2', 'Year 3', 'Year 4', 'Year 5', 'Year 6', 'Year 7', 'Year 8', 'Bachelors']
  end

  private

  def do_duplicate_checking
    if Rails.env.development? || Rails.env.test?
      DuplicateCheckerWorker.new.perform(self.id, Organization.current.short_name)
    else
      DuplicateCheckerWorker.perform_async(self.id, Organization.current.short_name)
    end
  end

  def update_related_family_member
    FamilyMember.delay.update_client_relevant_data(family_member.id, Apartment::Tenant.current) if family_member.present? && family_member.persisted?
  end

  def create_client_history
    ClientHistory.initial(self) if ENV['HISTORY_DATABASE_HOST'].present?
  end

  def notify_managers
    ClientMailer.exited_notification(self, User.without_deleted_users.managers.non_locked.pluck(:email)).deliver_now
  end

  def remove_family_from_case_worker
    if family
      clients = Client.joins(:users).where(current_family_id: family.id, case_worker_clients: { user_id: family.user_id })
      family.case_worker_families.destroy_all if clients.blank?
    else
      case_worker_clients.each do |case_worker_client|
        case_worker_client.user.families.each do |family|
          clients = family.clients.joins(:case_worker_clients).where(case_worker_clients: { user_id: case_worker_client&.user_id }, current_family_id: family.id).exists?
          family.case_worker_families.destroy_all if clients.blank?
        end
      end
    end
  end

  def mark_referral_as_saved
    referrals = find_referrals
    referrals.update_all(client_id: id, saved: true) if referrals.present?
  end

  def set_country_origin
    return if country_origin.present?

    country = current_setting.try(:country_name)
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
      times = { days: time_days }
    end
  end

  def address_contrain
    return unless Organization.current.country == 'cambdia'

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

  def save_client_global_organization
    @external_system_global = global_identity_organizations.find_or_initialize_by(global_id: global_id, organization_id: Organization.current&.id)
  end

  def save_global_identify_and_external_system_global_identities
    GlobalIdentity.find_or_create_by(ulid: global_id)
    @external_system_global.client_id = self.id
    @external_system_global.save

    save_external_system_global
  end

  def save_external_system_global
    if persisted? && external_id.present?
      external_system_global = global_identity.external_system_global_identities.find_by(external_id: external_id)
      external_system_global && external_system_global.update_attributes(client_slug: slug)
    end
  end

  def find_referrals
    referrals = []
    referrals ||= Referral.where(slug: archived_slug, saved: false) if archived_slug.present?

    referrals.presence || Referral.where(external_id: external_id, saved: false)
  end

  def update_first_referral_status
    received_referrals = referrals.received
    return if received_referrals.count.zero? || client_enrollments.any?

    referral = received_referrals.find_by(id: from_referral_id)
    return if referral.nil? || referral.referral_status != 'Referred' || referral.referred_from == Apartment::Tenant.current

    referral.level_of_risk = 'no action' if referral.level_of_risk.blank?
    referral.referral_status = status
    referral.save
  end

  def remove_tasks(case_worker)
    if case_worker.tasks.incomplete.exists?
      case_worker.tasks.incomplete.destroy_all
    end
  end

  def current_setting
    @current_setting ||= Setting.first_or_initialize
  end

  def delete_referee
    return if referee.nil? || referee.clients.where.not(id: id).any?

    referee.destroy
  end

  def flash_cache
    Rails.cache.delete([Apartment::Tenant.current, id, 'user_ids'])
    Rails.cache.delete([Apartment::Tenant.current, 'Client', 'location_of_concern']) if location_of_concern_changed?
    Rails.cache.delete([Apartment::Tenant.current, self.class.name, 'received_by', received_by_id]) if received_by_id_changed?
    Rails.cache.delete([Apartment::Tenant.current, self.class.name, 'followed_up_by', followed_up_by_id]) if followed_up_by_id_changed?
    Rails.cache.delete([Apartment::Tenant.current, 'Province', 'dropdown_list_option']) if province_id_changed?
    Rails.cache.delete([Apartment::Tenant.current, 'District', 'dropdown_list_option']) if district_id_changed?
    Rails.cache.delete([Apartment::Tenant.current, 'Commune', 'dropdown_list_option']) if commune_id_changed?
    Rails.cache.delete([Apartment::Tenant.current, 'Village', 'cache_village_name_by_client_commune_district_province']) if village_id_changed?
    Rails.cache.delete([Apartment::Tenant.current, 'Subdistrict', 'dropdown_list_option']) if subdistrict_id_changed?
    Rails.cache.delete([Apartment::Tenant.current, 'Township', 'dropdown_list_option']) if township_id_changed?
    Rails.cache.delete([Apartment::Tenant.current, 'State', 'dropdown_list_option']) if state_id_changed?
    cached_client_created_by_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_created_by/].blank? }
    cached_client_created_by_keys.each { |key| Rails.cache.delete(key) }
    cached_client_province_name_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_province_name/].blank? }
    cached_client_province_name_keys.each { |key| Rails.cache.delete(key) }
    cached_client_district_name_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_district_name/].blank? }
    cached_client_district_name_keys.each { |key| Rails.cache.delete(key) }
    cached_client_commune_name_kh_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_commune_name_kh/].blank? }
    cached_client_commune_name_kh_keys.each { |key| Rails.cache.delete(key) }
    cached_client_village_name_kh_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_village_name_kh/].blank? }
    cached_client_village_name_kh_keys.each { |key| Rails.cache.delete(key) }
    cached_client_referral_source_name_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_referral_source_name/].blank? }
    cached_client_referral_source_name_keys.each { |key| Rails.cache.delete(key) }
    cached_client_assessment_number_completed_date_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_assessment_number_completed_date/].blank? }
    cached_client_assessment_number_completed_date_keys.each { |key| Rails.cache.delete(key) }
    cached_client_sql_assessment_completed_date_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_sql_assessment_completed_date/].blank? }
    cached_client_sql_assessment_completed_date_keys.each { |key| Rails.cache.delete(key) }
    cached_client_assessment_order_completed_date_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_assessment_order_completed_date/].blank? }
    cached_client_assessment_order_completed_date_keys.each { |key| Rails.cache.delete(key) }
    cached_client_assessment_domains_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_assessment_domains/].blank? }
    cached_client_assessment_domains_keys.each { |key| Rails.cache.delete(key) }

    Rails.cache.delete([Apartment::Tenant.current, 'ReferralSource', 'cached_referral_source_try_name', referral_source_category_id]) if referral_source_category_id_changed?
    Rails.cache.delete([Apartment::Tenant.current, 'ReferralSource', 'cached_referral_source_try_name_en', referral_source_category_id]) if referral_source_category_id_changed?

    Rails.cache.delete([Apartment::Tenant.current, id, given_name_was || 'given_name']) if given_name_changed?
    Rails.cache.delete([Apartment::Tenant.current, id, given_name_was || 'given_name', 'export_excel']) if given_name_changed?
    Rails.cache.delete([Apartment::Tenant.current, id, family_name_was || 'family_name']) if family_name_changed?
    Rails.cache.delete([Apartment::Tenant.current, id, local_given_name_was || 'local_given_name']) if local_given_name_changed?
    Rails.cache.delete([Apartment::Tenant.current, id, local_family_name_was || 'local_family_name']) if local_family_name_changed?
    Rails.cache.fetch([I18n.locale, Apartment::Tenant.current, id, gender_was || 'gender']) if gender_changed?
    cached_client_custom_field_properties_count_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_custom_field_properties_count/].blank? }
    cached_client_custom_field_properties_count_keys.each { |key| Rails.cache.delete(key) }
    cached_client_custom_field_properties_order_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_custom_field_properties_order/].blank? }
    cached_client_custom_field_properties_order_keys.each { |key| Rails.cache.delete(key) }
    cached_client_custom_field_find_by_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_custom_field_find_by/].blank? }
    cached_client_custom_field_find_by_keys.each { |key| Rails.cache.delete(key) }
    cached_client_custom_field_properties_properties_by_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_custom_field_properties_properties_by/].blank? }
    cached_client_custom_field_properties_properties_by_keys.each { |key| Rails.cache.delete(key) }

    users.each do |user|
      program_streams.each do |progrm_stream|
        Rails.cache.delete([Apartment::Tenant.current, 'enrollable_client_ids', 'ProgramStream', 'User', progrm_stream.id, user.id])
        Rails.cache.delete([Apartment::Tenant.current, 'program_permission_editable', 'ProgramStream', 'User', progrm_stream.id, user.id])
      end
    end
    Rails.cache.delete([Apartment::Tenant.current, 'User', 'Client', id, 'tasks'])
  end

  def update_referral_status_on_target_ngo
    referral = referrals.received.last
    return if referral.blank? || referral.referred_from[/external system/i].present?

    current_ngo = Apartment::Tenant.current
    Apartment::Tenant.switch referral.referred_from
    original_referral = Referral.where(slug: referral.slug).last
    if original_referral
      original_referral.referral_status = status
      original_referral.save(validate: false)
    end
    Apartment::Tenant.switch current_ngo
  end
end
