class Client < ActiveRecord::Base

  CLIENT_STATUSES = ['Referred', 'Active EC', 'Active KC', 'Active FC', 'Independent - Monitored', 'Exited - Deseased', 'Exited - Age Out', 'Exited Independent', 'Exited Adopted', 'Exited Other']

  belongs_to :referral_source,  counter_cache: true
  belongs_to :province,         counter_cache: true
  belongs_to :user,             counter_cache: true
  belongs_to :school
  belongs_to :received_by,      class_name: 'User',     foreign_key: 'received_by_id',    counter_cache: true
  belongs_to :followed_up_by,   class_name: 'User',     foreign_key: 'followed_up_by_id', counter_cache: true
  belongs_to :birth_province,   class_name: 'Province', foreign_key: 'birth_province_id', counter_cache: true

  has_many :cases,       dependent: :destroy
  has_many :tasks,       dependent: :destroy
  has_many :case_notes,  dependent: :destroy
  has_many :assessments, dependent: :destroy

  has_and_belongs_to_many :agencies
  has_and_belongs_to_many :quantitative_cases

  scope :first_name_like,       -> (value) { where( "LOWER(clients.first_name) LIKE '%#{value.downcase}%'") }
  scope :last_name_like,        -> (value) { where( "LOWER(clients.last_name) LIKE '%#{value.downcase}%'") }
  scope :status_like,           ->         { CLIENT_STATUSES }
  scope :current_address_like,  -> (value) { where( "LOWER(clients.current_address) LIKE '%#{value.downcase}%'") }
  scope :school_name_like,      -> (value) { where( "LOWER(clients.school_name) LIKE '%#{value.downcase}%'") }
  scope :school_grade_like,     -> (value) { where( "LOWER(clients.school_grade) LIKE '%#{value.downcase}%'") }
  scope :referral_phone_like,   -> (value) { where( "LOWER(clients.referral_phone) LIKE '%#{value.downcase}%'") }
  scope :info_like,             -> (value) { where( "LOWER(clients.relevant_referral_information) LIKE '%#{value.downcase}%'") }

  scope :is_received_by,        -> { where.not(received_by_id: nil).map { |c| [c.received_by.name, c.received_by_id] if c.received_by }.uniq }
  scope :referral_source_is,    -> { where.not(referral_source_id: nil).map { |c| [c.referral_source.name, c.referral_source_id] if c.referral_source }.uniq }

  scope :is_followed_up_by,     -> { where.not(followed_up_by_id: nil).map { |c| [c.followed_up_by.name, c.followed_up_by_id] if c.followed_up_by }.uniq }
  scope :birth_province_is,     -> { where.not(birth_province_id: nil).map { |c| [c.birth_province.name, c.birth_province_id] if c.birth_province_id }.uniq }
  scope :province_is,           -> { where.not(province_id: nil).map { |c| [c.province.name, c.province_id] if c.province }.uniq }
  scope :case_worker_is,        -> { where.not(user_id: nil).map { |c| [c.user.name, c.user_id] if c.user }.uniq }

  scope :accepted,              -> { where(state: 'accepted') }
  scope :rejected,              -> { where(state: 'rejected') }

  scope :male,                  -> { where(gender: 'male') }
  scope :female,                -> { where(gender: 'female') }

  def name
    "#{first_name} #{last_name}"
  end

  def next_assessment_date
    return Date.today if assessments.count.zero?
    @next_date ||= assessments.most_recents.first.created_at + 6.months
  end

  def can_create_assessment?
    Date.today >= next_assessment_date
    # TODO: Remove hard coded(always returns true!!!)
    true
  end

  def can_create_case_note?
    assessments.count > 0
  end

end
