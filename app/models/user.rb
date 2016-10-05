class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  include DeviseTokenAuth::Concerns::User

  belongs_to :province,   counter_cache: true
  belongs_to :department, counter_cache: true

  has_many :cases
  has_many :clients
  has_many :changelogs
  has_many :progress_notes, dependent: :restrict_with_error

  validates :roles, presence: true

  scope :first_name_like, -> (value) { where('LOWER(users.first_name) LIKE ?', "%#{value.downcase}%") }

  scope :last_name_like,  -> (value) { where('LOWER(users.last_name) LIKE ?', "%#{value.downcase}%") }

  scope :mobile_like,     -> (value) { where('LOWER(users.mobile) LIKE ?', "%#{value.downcase}%") }

  scope :email_like,      -> (value) { where('LOWER(users.email) LIKE  ?', "%#{value.downcase}%") }

  scope :job_title_is,    ->         { where.not(job_title: '').pluck(:job_title).uniq }

  scope :department_is,   ->         { joins(:department).pluck('departments.name', 'departments.id').uniq }

  scope :case_workers,    ->         { where('users.roles LIKE ?', '%case worker%') }

  scope :admins,          ->         { where(roles: 'admin') }

  scope :province_is,     ->         { joins(:province).pluck('provinces.name', 'provinces.id').uniq }

  scope :has_clients,     ->         { joins(:clients).without_json_fields.uniq }

  before_save :assign_as_admin

  def name
    "#{first_name} #{last_name}"
  end

  def assign_as_admin
    self.admin = true if admin?
  end

  def self.without_json_fields
    select(column_names - ['tokens'])
  end

  def to_s
    name
  end

  def admin?
    roles == 'admin'
  end

  def case_worker?
    roles == 'case worker'
  end

  def able_manager?
    roles == 'able manager'
  end

  def ec_manager?
    roles == 'ec manager'
  end

  def fc_manager?
    roles == 'fc manager'
  end

  def kc_manager?
    roles == 'kc manager'
  end

  def any_case_manager?
    ec_manager? || fc_manager? || kc_manager?
  end

  def anyone?
    admin? || case_worker? || able_manager? || any_case_manager?
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
      if c.next_assessment_date < Date.today
        overdue << c
      elsif c.next_assessment_date == Date.today
        due_today << c
      end
    end

    [overdue.count, due_today.count]
  end
end
