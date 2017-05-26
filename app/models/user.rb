class User < ActiveRecord::Base
  include EntityTypeCustomField
  include EntityTypeCustomFieldNotification
  ROLES = ['admin', 'case worker', 'able manager', 'ec manager', 'fc manager', 'kc manager', 'manager', 'strategic overviewer'].freeze
  MANAGERS = ROLES.select { |role| role if role.include?('manager') }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_paper_trail

  include DeviseTokenAuth::Concerns::User

  belongs_to :province,   counter_cache: true
  belongs_to :department, counter_cache: true
  belongs_to :manager, class_name: 'User', foreign_key: :manager_id, required: false
  has_many :cases, dependent: :restrict_with_error
  has_many :changelogs, dependent: :restrict_with_error
  has_many :progress_notes, dependent: :restrict_with_error

  has_many :clients, dependent: :restrict_with_error
  has_many :tasks
  has_many :visits

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

  before_save :assign_as_admin

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
    ec_manager? || fc_manager? || kc_manager?
  end

  def any_manager?
    any_case_manager? || able_manager? || manager?
  end

  def no_any_associated_objects?
    clients_count.zero? && cases_count.zero? && tasks_count.zero? && changelogs_count.zero? && progress_notes.count.zero?
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
    entity_type_custom_field_notification(User.all)
  end

  def partner_custom_field_frequency_overdue_or_due_today
    entity_type_custom_field_notification(Partner.all)
  end

  def family_custom_field_frequency_overdue_or_due_today
    entity_type_custom_field_notification(Family.all)
  end

  def self.self_and_subordinates(user)
    if user.admin? || user.strategic_overviewer?
      User.all
    elsif user.manager?
      User.where('id = :user_id OR manager_id = :user_id', { user_id: user.id })
    elsif user.able_manager?
      ids = Client.able.pluck(:user_id) << user.id
      User.where(id: ids.uniq)
    elsif user.any_case_manager?
      ids = [user.id]
      if user.ec_manager?
        ids << Client.active_ec.pluck(:user_id)
      elsif user.fc_manager?
        ids << Client.active_fc.pluck(:user_id)
      elsif user.kc_manager?
        ids << Client.active_kc.pluck(:user_id)
      end
      User.where(id: ids.flatten.uniq)
    end
  end
end
