class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :province,   counter_cache: true
  belongs_to :department, counter_cache: true

  has_many :cases
  has_many :clients

  validates :roles, presence: true

  # validates :province_id, presence: true

  scope :first_name_like,     -> (value) { where("LOWER(users.first_name) LIKE '%#{value.downcase}%'") }

  scope :last_name_like,     -> (value) { where("LOWER(users.last_name) LIKE '%#{value.downcase}%'") }

  scope :mobile_like,   -> (value) { where("LOWER(users.mobile) LIKE '%#{value.downcase}%'") }

  scope :email_like,    -> (value) { where("LOWER(users.email) LIKE '%#{value.downcase}%'") }

  scope :job_title_is,  ->         { where.not(job_title: '').map{|caseworker| caseworker.job_title}.uniq }

  scope :department_is, ->         { where.not(department_id: nil).map{|c| [c.department.name, c.department_id] if c.department }.uniq }

  scope :case_workers,  ->         { where('users.roles LIKE ?', '%case worker%') }

  scope :province_is,                -> { where.not(province_id: nil).map { |u| [u.province.name, u.province_id] if u.province }.uniq }

  def name
    "#{first_name} #{last_name}"
  end

  def admin?
    roles.include?('admin')
  end

  def case_worker?
    roles.include?('case worker')
  end
end
