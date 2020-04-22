class User < ActiveRecord::Base
  include EntityTypeCustomField
  include EntityTypeCustomFieldNotification
  include NextClientEnrollmentTracking
  include ClientOverdueAndDueTodayForms

  ROLES = ['admin', 'manager', 'case worker', 'strategic overviewer'].freeze
  MANAGERS = ROLES.select { |role| role if role.include?('manager') }
  LANGUAGES = { en: :english, km: :khmer, my: :burmese }.freeze

  GENDER_OPTIONS = ['female', 'male', 'other', 'prefer not to say']

  devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :trackable, :validatable

  # has_one_time_password
  # enum otp_module: { otp_module_disabled: 0, otp_module_enabled: 1 }
  # attr_accessor :otp_code_token

  has_paper_trail

  include DeviseTokenAuth::Concerns::User

  belongs_to :province,   counter_cache: true
  belongs_to :department, counter_cache: true
  belongs_to :manager, class_name: 'User', foreign_key: :manager_id, required: false

  has_one :permission, dependent: :destroy

  has_many :visits,  dependent: :destroy
  has_many :advanced_searches, dependent: :destroy
  has_many :changelogs, dependent: :restrict_with_error
  has_many :case_worker_clients, dependent: :restrict_with_error
  has_many :clients, through: :case_worker_clients
  has_many :enter_ngo_users, dependent: :destroy
  has_many :enter_ngos, through: :enter_ngo_users
  has_many :tasks, dependent: :destroy
  has_many :calendars, dependent: :destroy
  has_many :visit_clients,  dependent: :destroy
  has_many :custom_field_properties, as: :custom_formable, dependent: :destroy
  has_many :custom_fields, through: :custom_field_properties, as: :custom_formable
  has_many :custom_field_permissions, -> { order_by_form_title }, dependent: :destroy
  has_many :user_custom_field_permissions, through: :custom_field_permissions
  has_many :program_stream_permissions, -> { order_by_program_name }, dependent: :destroy
  has_many :program_streams, through: :program_stream_permissions
  has_many :quantitative_type_permissions, -> { order_by_quantitative_type }, dependent: :destroy
  has_many :quantitative_types, through: :quantitative_type_permissions
  has_many :families, dependent: :nullify

  accepts_nested_attributes_for :custom_field_permissions
  accepts_nested_attributes_for :program_stream_permissions
  accepts_nested_attributes_for :quantitative_type_permissions
  accepts_nested_attributes_for :permission

  validates :roles, presence: true, inclusion: { in: ROLES }
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :gender, presence: true
  validates :pin_code, length: { is: 5 }, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true

  scope :first_name_like, ->(value) { where('first_name iLIKE ?', "%#{value.squish}%") }
  scope :last_name_like,  ->(value) { where('last_name iLIKE ?', "%#{value.squish}%") }
  scope :mobile_like,     ->(value) { where('mobile iLIKE ?', "%#{value.squish}%") }
  scope :email_like,      ->(value) { where('email iLIKE  ?', "%#{value.squish}%") }
  scope :males,           ->        { where(gender: 'male') }
  scope :females,         ->        { where(gender: 'female') }
  scope :in_department,   ->(value) { where('department_id = ?', value) }
  scope :job_title_are,   ->        { where.not(job_title: '').pluck(:job_title).uniq }
  scope :department_are,  ->        { joins(:department).pluck('departments.name', 'departments.id').uniq }
  scope :case_workers,    ->        { where(roles: 'case worker') }
  scope :admins,          ->        { where(roles: 'admin') }
  scope :province_are,    ->        { joins(:province).pluck('provinces.name', 'provinces.id').uniq }
  scope :has_clients,     ->        { joins(:clients).without_json_fields.uniq }
  scope :managers,        ->        { where(roles: MANAGERS) }
  scope :deleted_user,    ->        { where(deleted_at: nil) }
  scope :non_strategic_overviewers, -> { where.not(roles: 'strategic overviewer') }
  scope :staff_performances,        -> { where(staff_performance_notification: true) }
  scope :non_devs,                  -> { where.not(email: [ENV['DEV_EMAIL'], ENV['DEV2_EMAIL'], ENV['DEV3_EMAIL']]) }
  scope :non_locked,                -> { where(disable: false) }
  scope :notify_email,              -> { where(task_notify: true) }
  scope :referral_notification_email,    -> { where(referral_notification: true) }

  before_save :assign_as_admin
  before_save :set_manager_ids
  after_save :detach_manager, if: 'roles_changed?'
  after_save :toggle_referral_notification
  after_create :build_permission

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

  def assessment_either_overdue_or_due_today
    setting = Setting.first
    overdue   = []
    due_today = []
    customized_overdue   = []
    customized_due_today = []

    if self.deactivated_at.nil?
      clients.active_accepted_status.each do |client|
        next if !client.eligible_default_csi? && !(client.assessments.customs.present?)
        custom_assessment_setting_ids = client.assessments.customs.map{|ca| ca.domains.pluck(:custom_assessment_setting_id ) }.flatten.uniq
        if setting.enable_default_assessment? && setting.enable_custom_assessment?
          client_next_asseement_date = client.next_assessment_date.to_date
          if client_next_asseement_date < Date.today
            overdue << client
          elsif client_next_asseement_date == Date.today
            due_today << client
          end
          CustomAssessmentSetting.only_enable_custom_assessment.where(id: custom_assessment_setting_ids).each do |custom_assessment_setting|
            client_custom_next_assessment_date = client.custom_next_assessment_date(nil, custom_assessment_setting.id)&.to_date
            if  client_custom_next_assessment_date && client_custom_next_assessment_date < Date.today
              customized_overdue << client
            elsif  client_custom_next_assessment_date && client_custom_next_assessment_date == Date.today
              customized_due_today << client
            end
          end
        elsif setting.enable_default_assessment?
          client_next_asseement_date = client.next_assessment_date.to_date
          if client_next_asseement_date < Date.today
            overdue << client
          elsif client_next_asseement_date == Date.today
            due_today << client
          end
        elsif setting.enable_custom_assessment?
          CustomAssessmentSetting.only_enable_custom_assessment.where(id: custom_assessment_setting_ids).each do |custom_assessment_setting|
            client_custom_next_assessment_date = client.custom_next_assessment_date(nil, custom_assessment_setting.id).to_date
            if client_custom_next_assessment_date < Date.today
              customized_overdue << client
            elsif client_custom_next_assessment_date == Date.today
              customized_due_today << client
            end
          end
        end
      end
    else
      clients.active_accepted_status.each do |client|
        next if !client.eligible_default_csi? && !(client.assessments.customs.present?)
        custom_assessment_setting_ids = client.assessments.customs.map{|ca| ca.domains.pluck(:custom_assessment_setting_id ) }.flatten.uniq
        if setting.enable_default_assessment? && setting.enable_custom_assessment?
          client_next_asseement_date = client.next_assessment_date(self.activated_at)
          if client_next_asseement_date.present? && client_next_asseement_date.to_date < Date.today
            overdue << client
          elsif client_next_asseement_date.present? && client_next_asseement_date.to_date == Date.today
            due_today << client
          end
          CustomAssessmentSetting.only_enable_custom_assessment.where(id: custom_assessment_setting_ids).each do |custom_assessment_setting|
            client_custom_next_assessment_date = client.custom_next_assessment_date(nil, custom_assessment_setting.id)&.to_date
            if client_custom_next_assessment_date.present? && client_custom_next_assessment_date.to_date < Date.today
              customized_overdue << client
            elsif client_custom_next_assessment_date.present? && client_custom_next_assessment_date.to_date == Date.today
              customized_due_today << client
            end
          end
        elsif setting.enable_default_assessment?
          client_next_asseement_date = client.next_assessment_date(self.activated_at)
          next if client_next_asseement_date.nil?
          if client_next_asseement_date.to_date < Date.today
            overdue << client
          elsif client_next_asseement_date.to_date == Date.today
            due_today << client
          end
        elsif setting.enable_custom_assessment?
          CustomAssessmentSetting.only_enable_custom_assessment.where(id: custom_assessment_setting_ids).each do |custom_assessment_setting|
            client_custom_next_assessment_date = client.custom_next_assessment_date(self.activated_at, custom_assessment_setting.id)&.to_date
            if client_custom_next_assessment_date.present? && client_custom_next_assessment_date.to_date < Date.today
              customized_overdue << client
            elsif client_custom_next_assessment_date.present? && client_custom_next_assessment_date.to_date == Date.today
              customized_due_today << client
            end
          end
        end
      end
    end
    { overdue_count: overdue.count, due_today_count: due_today.count, custom_overdue_count: customized_overdue.count, custom_due_today_count: customized_due_today.count }
  end

  def client_custom_field_frequency_overdue_or_due_today
    entity_type_custom_field_notification(clients.active_accepted_status)
  end

  def user_custom_field_frequency_overdue_or_due_today
    if self.manager?
      entity_type_custom_field_notification(User.where('manager_ids && ARRAY[?]', self.id))
    elsif self.admin?
      entity_type_custom_field_notification(User.all)
    end
  end

  def partner_custom_field_frequency_overdue_or_due_today
    if self.admin? || self.manager?
      entity_type_custom_field_notification(Partner.all)
    end
  end

  def family_custom_field_frequency_overdue_or_due_today
    if self.admin?
      entity_type_custom_field_notification(Family.all)
    elsif self.manager?
      subordinate_users = User.where('manager_ids && ARRAY[:user_id] OR id = :user_id', { user_id: self.id }).map(&:id)
      family_ids = []
      exited_client_ids = exited_clients(subordinate_users)

      family_ids += User.joins(:clients).where(id: subordinate_users).where.not(clients: { current_family_id: nil }).select('clients.current_family_id AS client_current_family_id').map(&:client_current_family_id)
      family_ids += Client.where(id: exited_client_ids).pluck(:current_family_id)
      family_ids += self.clients.pluck(:current_family_id)

      families = Family.where(id: family_ids).or(Family.where(user_id: self.id))
      entity_type_custom_field_notification(families)
    elsif self.case_worker?
      family_ids = []
      self.clients.each do |client|
        family_ids << client.family.try(:id)
      end
      families = Family.where(id: family_ids).or(Family.where(user_id: self.id))
      entity_type_custom_field_notification(families)
    end
  end

  def client_forms_overdue_or_due_today
    if self.deactivated_at.present?
      active_accepted_clients = clients.where(created_at > self.activated_at).active_accepted_status
    else
      active_accepted_clients = clients.active_accepted_status
    end
    overdue_and_due_today_forms(active_accepted_clients)
  end

  def case_note_overdue_and_due_today
    overdue   = []
    due_today = []

    if self.deactivated_at.nil?
      clients.active_accepted_status.each do |client|
        client_next_case_note_date = client.next_case_note_date.to_date
        if client_next_case_note_date < Date.today
          overdue << client
        elsif client_next_case_note_date == Date.today
          due_today << client
        end
      end
    else
      clients.active_accepted_status.each do |client|
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

  def self.self_and_subordinates(user)
    if user.admin? || user.strategic_overviewer?
      User.all
    elsif user.manager?
      User.where('id = :user_id OR manager_ids && ARRAY[:user_id]', { user_id: user.id })
    end
  end

  def detach_manager
    if roles.in?(['strategic overviewer', 'admin'])
      User.where(manager_id: self.id).update_all(manager_id: nil, manager_ids: [])
    end
  end

  def set_manager_ids
    if manager_id.nil? || roles.in?(['strategic overviewer', 'admin'])
      self.manager_id = nil
      self.manager_ids = []
      return if manager_id_was == self.id
      update_manager_ids(self)
    else
      the_manager_ids = User.find(self.manager_id).manager_ids
      update_manager_ids(self, the_manager_ids.push(self.manager_id).flatten.compact.uniq)
    end
  end

  def update_manager_ids(user, the_manager_ids = [])
    user.manager_ids = the_manager_ids
    user.save unless user.id == id
    return if user.case_worker?
    case_workers = User.where(manager_id: user.id)
    if case_workers.present?
      case_workers.each do |case_worker|
        next if case_worker.id == self.id
        update_manager_ids(case_worker, the_manager_ids.push(user.id).flatten.compact.uniq)
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
    roles.include?(user_role)? CustomField.order('lower(form_title)') : CustomField.client_forms.order('lower(form_title)')
  end

  def populate_program_streams
    ProgramStream.order('lower(name)').each do |ps|
      program_stream_permissions.build(program_stream_id: ps.id)
    end
  end

  def populate_quantitative_types
    QuantitativeType.order('lower(name)').each do |qt|
      quantitative_type_permissions.build(quantitative_type_id: qt.id)
    end
  end

  # def otp_module_changeable?
  #   # set it to false until the client request this feature
  #   # as the user is unable to access their device/token
  #   false
  # end

  private

  def toggle_referral_notification
    return unless roles_changed? && roles == 'admin'
    self.update_columns(referral_notification: true)
  end

  def exited_clients(user_ids)
    sql = user_ids.map do |user_id|
      "versions.object_changes ILIKE '%user_id:\n- \n- #{user_id}\n%'"
    end.join(" OR ")
    client_ids = PaperTrail::Version.where(item_type: 'CaseWorkerClient', event: 'create').where(sql).map do |version|
      client_id = version.changeset[:client_id].last
    end

    Client.where(id: client_ids, status: 'Exited').ids
  end
end
