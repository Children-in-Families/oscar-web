class User < ActiveRecord::Base
  ROLES = ['admin', 'case worker', 'able manager', 'ec manager', 'fc manager', 'kc manager']

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  include DeviseTokenAuth::Concerns::User

  belongs_to :province,   counter_cache: true
  belongs_to :department, counter_cache: true
  has_many :cases
  has_many :clients
  has_many :changelogs
  has_many :progress_notes, dependent: :restrict_with_error

  has_paper_trail

  validates :roles, presence: true

  scope :first_name_like, -> (value) { where('LOWER(users.first_name) LIKE ?', "%#{value.downcase}%") }
  scope :last_name_like,  -> (value) { where('LOWER(users.last_name) LIKE ?', "%#{value.downcase}%") }
  scope :mobile_like,     -> (value) { where('LOWER(users.mobile) LIKE ?', "%#{value.downcase}%") }
  scope :email_like,      -> (value) { where('LOWER(users.email) LIKE  ?', "%#{value.downcase}%") }
  scope :job_title_are,   ->         { where.not(job_title: '').pluck(:job_title).uniq }
  scope :department_are,  ->         { joins(:department).pluck('departments.name', 'departments.id').uniq }
  scope :case_workers,    ->         { where('users.roles LIKE ?', '%case worker%') }
  scope :admins,          ->         { where(roles: 'admin') }
  scope :province_are,    ->         { joins(:province).pluck('provinces.name', 'provinces.id').uniq }
  scope :has_clients,     ->         { joins(:clients).without_json_fields.uniq }

  before_save :assign_as_admin

  ROLES.each do |role|
    define_method("#{role.parameterize.underscore}?") do
      roles == role
    end
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
    any_case_manager? || able_manager?
  end

  def has_no_any_associated_objects?
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
    clients.where(status: ['Active EC','Active FC','Active KC']).each do |c|
      if c.next_assessment_date.to_date < Date.today
        overdue << c
      elsif c.next_assessment_date.to_date == Date.today
        due_today << c
      end
    end

    { overdue_count: overdue.count, due_today_count: due_today.count }
  end
end
