class User < ActiveRecord::Base
  include EntityTypeCustomField
  include EntityTypeCustomFieldNotification
  include NextClientEnrollmentTracking
  include ClientOverdueAndDueTodayForms
  include NotificationMappingConcern
  include CsiConcern
  include CacheAll

  ROLES = ['admin', 'manager', 'case worker', 'hotline officer', 'strategic overviewer'].freeze
  MANAGERS = ROLES.select { |role| role if role.include?('manager') }
  LANGUAGES = { en: :english, km: :khmer, my: :burmese }.freeze

  GENDER_OPTIONS = ['female', 'male', 'lgbt', 'unknown', 'prefer_not_to_say', 'other']

  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable

  has_paper_trail

  include DeviseTokenAuth::Concerns::User

  belongs_to :province, counter_cache: true
  belongs_to :department, counter_cache: true
  belongs_to :manager, class_name: 'User', foreign_key: :manager_id, required: false

  has_one :permission, dependent: :destroy

  has_many :visits, dependent: :destroy
  has_many :advanced_searches, dependent: :destroy
  has_many :changelogs, dependent: :restrict_with_error
  has_many :case_worker_clients, dependent: :restrict_with_error
  has_many :clients, through: :case_worker_clients
  has_many :enter_ngo_users, dependent: :destroy
  has_many :enter_ngos, through: :enter_ngo_users
  has_many :notifications, dependent: :destroy

  has_many :tasks, dependent: :destroy
  has_many :incomplete_tasks, -> { incomplete }, class_name: 'Task'

  has_many :calendars, dependent: :destroy
  has_many :visit_clients, dependent: :destroy
  has_many :custom_field_properties, as: :custom_formable, dependent: :destroy
  has_many :custom_fields, through: :custom_field_properties, as: :custom_formable
  has_many :custom_field_permissions, -> { order_by_form_title }, dependent: :destroy
  has_many :user_custom_field_permissions, through: :custom_field_permissions
  has_many :program_stream_permissions, -> { order_by_program_name }, dependent: :destroy
  has_many :program_streams, through: :program_stream_permissions
  has_many :quantitative_type_permissions, -> { order_by_quantitative_type }, dependent: :destroy
  has_many :quantitative_types, through: :quantitative_type_permissions
  has_many :families, dependent: :nullify
  has_many :case_conference_users, dependent: :destroy
  has_many :case_conferences, through: :case_conference_users
  has_many :internal_referrals, dependent: :destroy
  has_many :program_stream_users, dependent: :destroy
  has_many :propgram_streams, through: :program_stream_users

  accepts_nested_attributes_for :custom_field_permissions
  accepts_nested_attributes_for :program_stream_permissions
  accepts_nested_attributes_for :quantitative_type_permissions
  accepts_nested_attributes_for :permission

  validates :roles, presence: true, inclusion: { in: ROLES }
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :gender, presence: true
  validates :pin_code, length: { is: 5 }, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true

  scope :first_name_like, -> (value) { where('first_name iLIKE ?', "%#{value.squish}%") }
  scope :last_name_like, -> (value) { where('last_name iLIKE ?', "%#{value.squish}%") }
  scope :mobile_like, -> (value) { where('mobile iLIKE ?', "%#{value.squish}%") }
  scope :email_like, -> (value) { where('email iLIKE  ?', "%#{value.squish}%") }
  scope :males, -> { where(gender: 'male') }
  scope :females, -> { where(gender: 'female') }
  scope :in_department, -> (value) { where('department_id = ?', value) }
  scope :job_title_are, -> { where.not(job_title: '').pluck(:job_title).uniq }
  scope :department_are, -> { joins(:department).pluck('departments.name', 'departments.id').uniq }
  scope :case_workers, -> { where(roles: 'case worker') }
  scope :hotline_officer, -> { where(roles: 'hotline officer') }
  scope :admins, -> { where(roles: 'admin') }
  scope :province_are, -> { joins(:province).pluck('provinces.name', 'provinces.id').uniq }
  scope :has_clients, -> { joins(:clients).without_json_fields.uniq }
  scope :managers, -> { where(roles: MANAGERS) }
  scope :deleted_users, -> { where.not(deleted_at: nil) }
  scope :without_deleted_users, -> { where(deleted_at: nil) }
  scope :non_strategic_overviewers, -> { where.not(roles: 'strategic overviewer') }
  scope :staff_performances, -> { where(staff_performance_notification: true) }
  scope :non_devs, -> { where.not(email: [ENV['DEV_EMAIL'], ENV['DEV2_EMAIL'], ENV['DEV3_EMAIL']]) }
  scope :non_locked, -> { where(disable: false) }
  scope :notify_email, -> { where(task_notify: true) }
  scope :referral_notification_email, -> { where(referral_notification: true) }
  scope :oscar_or_dev, -> { where(email: [ENV['OSCAR_TEAM_EMAIL'], ENV['DEV_EMAIL'], ENV['DEV2_EMAIL'], ENV['DEV3_EMAIL']]) }

  before_save :assign_as_admin
  after_commit :set_manager_ids
  after_save :detach_manager, if: 'roles_changed?'
  after_save :toggle_referral_notification
  after_create :build_permission
  after_commit :flush_cache

  class << self
    def current_user=(user)
      Thread.current[:current_user] = user
    end

    def current_user
      Thread.current[:current_user]
    end

    def cache_case_workers
      Rails.cache.fetch([Apartment::Tenant.current, self.name, 'case_workers']) { self.case_workers }
    end

    def cach_has_clients_case_worker_options(reload: false)
      Rails.cache.fetch([Apartment::Tenant.current, self.name, 'cach_has_clients_case_worker_options']) { self.has_clients.map { |user| ["#{user.first_name} #{user.last_name}", user.id] } }
    end
  end

  def build_permission
    unless self.strategic_overviewer?
      self.create_permission

      CustomField.all.each do |cf|
        self.custom_field_permissions.create(custom_field_id: cf.id)
      end

      ProgramStream.all.each do |ps|
        self.program_stream_permissions.create(program_stream_id: ps.id)
      end

      QuantitativeType.all.each do |qt|
        self.quantitative_type_permissions.create(quantitative_type_id: qt.id)
      end
    end
  end

  ROLES.each do |role|
    define_method("#{role.parameterize.underscore}?") do
      roles == role
    end
  end

  def active_for_authentication?
    super && !disable?
  end

  def name
    "#{first_name} #{last_name}"
  end

  def assign_as_admin
    self.admin = true if admin?
  end

  def self.without_json_fields
    select(column_names - ['tokens'])
  end

  def any_case_manager?
    manager?
  end

  def any_manager?
    manager?
  end

  def no_any_associated_objects?
    clients.count.zero? && changelogs.count.zero?
  end

  def client_status
    case roles
    when 'ec manager'
      'Active EC'
    when 'fc manager'
      'Active FC'
    when 'kc manager'
      'Active KC'
    end
  end

  def assessment_either_overdue_or_due_today(clients, setting)
    csi_assessments = assessment_due_today(clients, setting)
    custom_assessments = custom_assessment_due

    csi_assessments.merge(custom_assessments)
  end

  def assessment_due_today(eligible_clients, setting)
    due_today_assessments = []
    overdue_assessments = []
    Rails.cache.delete([Apartment::Tenant.current, self.class.name, id, 'assessment_either_overdue_or_due_today'])
    Rails.cache.fetch([Apartment::Tenant.current, self.class.name, id, 'assessment_either_overdue_or_due_today']) do
      overdue_assessments = Assessment.joins(:client).merge(
        eligible_clients
      ).where("DATE(assessments.created_at + interval '#{setting.max_assessment}' #{setting.assessment_frequency}) < CURRENT_DATE")
        .select(
          :id, :created_at, 'clients.slug as client_slug',
          "TRIM(CONCAT(CONCAT(clients.given_name, ' ', clients.family_name), ' ', CONCAT(clients.local_family_name, ' ', clients.local_given_name))) as client_name"
        ).to_a

      due_today_assessments = Assessment.joins(:client).merge(
        eligible_clients
      ).where("DATE(assessments.created_at + interval '#{setting.max_assessment}' #{setting.assessment_frequency}) = CURRENT_DATE")
        .select(
          :id, :created_at, 'clients.slug as client_slug',
          "TRIM(CONCAT(CONCAT(clients.given_name, ' ', clients.family_name), ' ', CONCAT(clients.local_family_name, ' ', clients.local_given_name))) as client_name"
        ).to_a

      {
        overdue_count: overdue_assessments.count,
        overdue_assessment: overdue_assessments,
        due_today: due_today_assessments.count,
        due_today_assessment_date: []
      }
    end
  end

  def custom_assessment_due
    customized_due_today = { client_id: [], custom_assessment_setting: [] }
    custom_assessment_due_today = []
    custom_assessment_overdue = []
    CustomAssessmentSetting.only_enable_custom_assessment.map do |custom_setting|
      sql = custom_setting.custom_assessment_frequency == 'unlimited' ? 'DATE(assessments.created_at)' : "DATE(assessments.created_at + interval '#{custom_setting.max_custom_assessment}' #{custom_setting.custom_assessment_frequency})"
      custom_assessments = Assessment.customs.joins(:client).where(custom_assessment_setting_id: custom_setting.id)
      custom_assessment_overdue << custom_assessments.merge(
        user_clients.active_accepted_status
          .where('(EXTRACT(year FROM age(current_date, coalesce(clients.date_of_birth, CURRENT_DATE))) :: int) < ?', custom_setting.custom_age || 18)
      ).where("#{sql} < CURRENT_DATE").select(
            :id, :created_at, 'clients.slug as client_slug',
            "TRIM(CONCAT(CONCAT(clients.given_name, ' ', clients.family_name), ' ', CONCAT(clients.local_family_name, ' ', clients.local_given_name))) as client_name"
          ).to_a

      custom_assessment_due_today << custom_assessments.merge(
        user_clients.active_accepted_status
          .where('(EXTRACT(year FROM age(current_date, coalesce(clients.date_of_birth, CURRENT_DATE))) :: int) < ?', custom_setting.custom_age || 18)
      ).where("#{sql} = CURRENT_DATE").select(
            :id, :created_at, 'clients.slug as client_slug',
            "TRIM(CONCAT(CONCAT(clients.given_name, ' ', clients.family_name), ' ', CONCAT(clients.local_family_name, ' ', clients.local_given_name))) as client_name"
          ).to_a
    end

    {
      custom_overdue_count: custom_assessment_overdue.flatten.uniq.count,
      custom_due_today: custom_assessment_due_today.flatten.uniq.count,
      custom_due_today_assessment_date: customized_due_today[:custom_assessment_setting]
    }
  end

  def assessment_overdue(client_id, next_assessment_date)
    [client_id, next_assessment_date] if next_assessment_date.to_date < Date.today
  end

  def client_custom_field_frequency_overdue_or_due_today(_clients)
    entity_type_custom_field_notification(_clients.active_accepted_status)
  end

  def user_custom_field_frequency_overdue_or_due_today
    if self.manager?
      entity_type_custom_field_notification(User.where('manager_ids && ARRAY[?]', self.id))
    elsif self.hotline_officer?
      entity_type_custom_field_notification(User.where(id: self.id))
    elsif self.admin?
      entity_type_custom_field_notification(User.all)
    end
  end

  def partner_custom_field_frequency_overdue_or_due_today
    if self.admin? || self.manager? || self.hotline_officer?
      entity_type_custom_field_notification(Partner.all)
    end
  end

  def family_custom_field_frequency_overdue_or_due_today(_clients)
    if self.admin? || self.hotline_officer?
      entity_type_custom_field_notification(Family.all)
    elsif self.manager?
      subordinate_users = User.self_and_subordinates(self).map(&:id)
      family_ids = []
      exited_client_ids = exited_clients(subordinate_users)

      family_ids += User.joins(:clients).where(id: subordinate_users).where.not(clients: { current_family_id: nil }).select('clients.current_family_id AS client_current_family_id').map(&:client_current_family_id)
      family_ids += _clients.where(id: exited_client_ids).pluck(:current_family_id)
      family_ids += _clients.pluck(:current_family_id)

      families = Family.where(id: family_ids).or(Family.where(user_id: self.id))
      entity_type_custom_field_notification(families)
    elsif self.case_worker?
      family_ids = []
      _clients.each do |client|
        family_ids << client.family.try(:id)
      end
      families = Family.where(id: family_ids).or(Family.where(user_id: self.id))
      entity_type_custom_field_notification(families)
    end
  end

  def client_forms_overdue_or_due_today(active_clients = nil)
    if self.deactivated_at.present?
      active_accepted_clients = (active_clients || user_clients).where('clients.created_at > ?', self.activated_at).active_accepted_status
    else
      active_accepted_clients = (active_clients || user_clients).active_accepted_status
    end
    overdue_and_due_today_forms(self, active_accepted_clients)
  end

  def case_notes_due_today_and_overdue(user_clients)
    overdue = []
    due_today = []

    if self.deactivated_at.nil?
      user_clients.active_accepted_status.includes(:case_notes).each do |client|
        next unless client.case_notes.any?

        client_next_case_note_date = client.next_case_note_date.to_date
        if client_next_case_note_date < Date.today
          overdue << client
        elsif client_next_case_note_date == Date.today
          due_today << client
        end
      end
    else
      user_clients.active_accepted_status.includes(:case_notes).each do |client|
        next unless client.case_notes.any?

        client_next_case_note_date = client.next_case_note_date(self.activated_at)
        next if client_next_case_note_date.nil?

        if client_next_case_note_date.to_date < Date.today
          overdue << client
        elsif client_next_case_note_date.to_date == Date.today
          due_today << client
        end
      end
    end

    { client_overdue: overdue, client_due_today: due_today }
  end

  def user_clients
    user_ability = Ability.new(self)
    @user_clients ||= Client.accessible_by(user_ability).select(:id, :slug, :status, :given_name, :family_name, :local_given_name, :local_family_name, :date_of_birth)
  end

  def self.self_and_subordinates(user)
    if user.admin? || user.strategic_overviewer?
      User.all
    elsif user.hotline_officer?
      User.where(id: user.id)
    elsif user.manager?
      User.where('id = :user_id OR manager_ids && ARRAY[:user_id]', { user_id: user.id })
    end
  end

  def detach_manager
    if roles.in?(['strategic overviewer', 'admin'])
      User.where(manager_id: self.id).update_all(manager_id: nil, manager_ids: [])
      User.where('id = :user_id OR manager_ids && ARRAY[:user_id]', { user_id: self.id }).each do |user|
        user.manager_ids = find_manager_manager(user.manager_id, user.manager_ids)
        user.save
      end
      self.update_columns(manager_id: nil, manager_ids: [])
    end
  end

  def set_manager_ids
    if manager_id.nil? || roles.in?(['strategic overviewer', 'admin'])
      self.manager_id = nil
      self.manager_ids = []
      return if manager_id_was == self.id
      update_manager_ids(self)
    else
      self.update_column(:manager_id, self.manager_id) if self.persisted?
      the_manager_ids = User.find_by(id: self.manager_id)&.manager_ids || []
      update_manager_ids(self, the_manager_ids.push(self.manager_id).flatten.compact.uniq)
    end
  end

  def update_manager_ids(user, the_manager_ids = [])
    user.update_column(:manager_ids, find_manager_manager(user.manager_id, the_manager_ids)) if user.persisted?
    user.save unless user.id == id
    return if user.case_worker?

    subordinators = User.where(manager_id: user.id)
    if subordinators.present?
      subordinators.each do |subordinator|
        next if subordinator.id == self.id

        update_manager_ids(subordinator, the_manager_ids.push(user.id).flatten.compact.uniq)
      end
    end
  end

  def populate_custom_fields
    custom_fields = get_custom_fields_by_role

    custom_fields.each do |cf|
      custom_field_permissions.build(custom_field_id: cf.id)
    end
  end

  def get_custom_fields_by_role
    roles = ['admin', 'manager']
    user_role = self.roles
    roles.include?(user_role) ? CustomField.order('lower(form_title)') : CustomField.client_forms.order('lower(form_title)')
  end

  def populate_program_streams
    ProgramStream.order('lower(name)').where.not(id: program_streams.ids).each do |ps|
      program_stream_permissions.build(program_stream_id: ps.id)
    end
  end

  def populate_quantitative_types
    QuantitativeType.order('lower(name)').each do |qt|
      quantitative_type_permissions.build(quantitative_type_id: qt.id)
    end
  end

  def cache_advance_saved_search
    Rails.cache.fetch([Apartment::Tenant.current, self.class.name, self.id, 'advance_saved_search']) { self.advanced_searches.for_client.to_a }
  end

  def self.cached_user_select_options
    Rails.cache.fetch([Apartment::Tenant.current, 'User', 'user_select_options']) do
      User.non_strategic_overviewers.order(:first_name, :last_name).map { |user| { user.id.to_s => user.name } }
    end
  end

  def fetch_notification
    Rails.cache.delete([Apartment::Tenant.current, 'notifications', 'user', id])
    Rails.cache.fetch([Apartment::Tenant.current, 'notifications', 'user', id]) do
      notifications = UserNotification.new(self, user_clients)
      notifications = JSON.parse(notifications.to_json)
      map_notification_payloads(notifications)
    end
  end

  private

  def toggle_referral_notification
    return unless roles_changed? && roles == 'admin'

    self.update_columns(referral_notification: true)
  end

  def find_manager_manager(the_manager_id, manager_manager_ids = [])
    if manager_manager_ids.present?
      subordinators = User.where(id: manager_manager_ids)
    else
      subordinators = User.self_and_subordinates(self)
    end

    return manager_manager_ids unless subordinators

    managers_ids = subordinators.pluck(:manager_ids)
    manager_manager_ids & (managers_ids << the_manager_id).flatten.compact.uniq
  end

  def exited_clients(user_ids)
    client_ids = CaseWorkerClient.where(id: PaperTrail::Version.where(item_type: 'CaseWorkerClient', event: 'create').joins(:version_associations).where(version_associations: { foreign_key_name: 'user_id', foreign_key_id: user_ids }).distinct.map(&:item_id)).pluck(:client_id).uniq
    Client.where(id: client_ids, status: 'Exited').ids
  end

  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, 'User', 'user_select_options'])
  end
end
