class User < ActiveRecord::Base
  include EntityTypeCustomField
  include EntityTypeCustomFieldNotification
  include NextClientEnrollmentTracking
  include ClientEnrollmentTrackingNotification

  ROLES = ['admin', 'case worker', 'able manager', 'ec manager', 'fc manager', 'kc manager', 'manager', 'strategic overviewer'].freeze
  MANAGERS = ROLES.select { |role| role if role.include?('manager') }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_paper_trail

  include DeviseTokenAuth::Concerns::User

  belongs_to :province,   counter_cache: true
  belongs_to :department, counter_cache: true
  belongs_to :manager, class_name: 'User', foreign_key: :manager_id, required: false

  has_many :changelogs, dependent: :restrict_with_error
  has_many :progress_notes, dependent: :restrict_with_error
  has_many :case_worker_clients, dependent: :restrict_with_error
  has_many :clients, through: :case_worker_clients
  has_many :case_worker_tasks, dependent: :destroy
  has_many :tasks, through: :case_worker_tasks
  has_many :calendars
  has_many :visits,  dependent: :destroy
  has_many :visit_clients,  dependent: :destroy
  has_many :custom_field_properties, as: :custom_formable, dependent: :destroy
  has_many :custom_fields, through: :custom_field_properties, as: :custom_formable

  validates :roles, presence: true, inclusion: { in: ROLES }
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  scope :first_name_like, ->(value) { where('first_name iLIKE ?', "%#{value}%") }
  scope :last_name_like,  ->(value) { where('last_name iLIKE ?', "%#{value}%") }
  scope :mobile_like,     ->(value) { where('mobile iLIKE ?', "%#{value}%") }
  scope :email_like,      ->(value) { where('email iLIKE  ?', "%#{value}%") }
  scope :in_department,   ->(value) { where('department_id = ?', value) }
  scope :job_title_are,   ->        { where.not(job_title: '').pluck(:job_title).uniq }
  scope :department_are,  ->        { joins(:department).pluck('departments.name', 'departments.id').uniq }
  scope :case_workers,    ->        { where(roles: 'case worker') }
  scope :admins,          ->        { where(roles: 'admin') }
  scope :province_are,    ->        { joins(:province).pluck('provinces.name', 'provinces.id').uniq }
  scope :has_clients,     ->        { joins(:clients).without_json_fields.uniq }
  scope :managers,        ->        { where(roles: MANAGERS) }
  scope :able_managers,   ->        { where(roles: 'able manager') }
  scope :ec_managers,     ->        { where(roles: 'ec manager') }
  scope :fc_managers,     ->        { where(roles: 'fc manager') }
  scope :kc_managers,     ->        { where(roles: 'kc manager') }
  scope :non_strategic_overviewers, -> { where.not(roles: 'strategic overviewer') }
  scope :staff_performances,         -> { where(staff_performance_notification: true) }

  before_save :assign_as_admin
  before_save :set_manager_ids, if: 'manager_id_changed?'
  after_save :reset_manager, if: 'roles_changed?'

  ROLES.each do |role|
    define_method("#{role.parameterize.underscore}?") do
      roles == role
    end
  end

  def active_for_authentication?
    super && !disable?
  end

  def name
    full_name = "#{first_name} #{last_name}"
    full_name.present? ? full_name : 'Unknown'
  end

  def assign_as_admin
    self.admin = true if admin?
  end

  def self.without_json_fields
    select(column_names - ['tokens'])
  end

  def any_case_manager?
    ec_manager? || fc_manager? || kc_manager?
  end

  def any_manager?
    any_case_manager? || able_manager? || manager?
  end

  def no_any_associated_objects?
    clients_count.zero? && tasks_count.zero? && changelogs_count.zero? && progress_notes.count.zero?
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
    overdue   = []
    due_today = []
    clients.all_active_types.each do |client|
      client_next_asseement_date = client.next_assessment_date.to_date
      if client_next_asseement_date < Date.today
        overdue << client
      elsif client_next_asseement_date == Date.today
        due_today << client
      end
    end
    { overdue_count: overdue.count, due_today_count: due_today.count }
  end

  def assessments_overdue
    clients.all_active_types
  end

  def client_custom_field_frequency_overdue_or_due_today
    entity_type_custom_field_notification(clients)
  end

  def user_custom_field_frequency_overdue_or_due_today
    if self.manager?
      entity_type_custom_field_notification(User.where('manager_ids && ARRAY[?]', self.id))
    elsif self.admin?
      entity_type_custom_field_notification(User.all)
    end
  end

  def partner_custom_field_frequency_overdue_or_due_today
    if self.admin? || self.any_case_manager? || self.manager?
      entity_type_custom_field_notification(Partner.all)
    end
  end

  def family_custom_field_frequency_overdue_or_due_today
    if self.admin? || self.any_case_manager? || self.manager?
      entity_type_custom_field_notification(Family.all)
    end

  end

  def client_enrollment_tracking_overdue_or_due_today
    client_enrollment_tracking_notification(clients)
  end

  def self.self_and_subordinates(user)
    if user.admin? || user.strategic_overviewer?
      User.all
    elsif user.manager?
      User.where('id = :user_id OR manager_ids && ARRAY[:user_id]', { user_id: user.id })
    elsif user.able_manager?
      user_ids = Client.able.map(&:user_ids).flatten << user.id
      User.where(id: user_ids.uniq)
    elsif user.any_case_manager?
      user_ids = [user.id]
      if user.ec_manager?
        user_ids << Client.active_ec.map(&:user_ids).flatten
      elsif user.fc_manager?
        user_ids << Client.active_fc.map(&:user_ids).flatten
      elsif user.kc_manager?
        user_ids << Client.active_kc.map(&:user_ids).flatten
      end
      User.where(id: user_ids.flatten.uniq)
    end
  end

  def reset_manager
    if roles_change.last == 'case worker' || roles_change.last == 'strategic overviewer'
      User.where(manager_id: self).map{|u| u.update(manager_id: nil)}
    end
  end

  def set_manager_ids
    if manager_id.nil?
      self.manager_ids = []
      manager_id = self.id
      update_manager_ids(self)
    else
      manager_ids = User.find(self.manager_id).manager_ids
      update_manager_ids(self, manager_ids.unshift(self.manager_id))
    end
  end

  def update_manager_ids(user, manager_ids = [])
    user.manager_ids = manager_ids
    user.save unless user.id == id
    return if user.case_worker?
    case_workers = User.where(manager_id: user.id)
    if case_workers.present?
      case_workers.each do |case_worker|
        update_manager_ids(case_worker, manager_ids.unshift(user.id))
      end
    end
  end
end
