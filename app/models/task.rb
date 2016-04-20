class Task < ActiveRecord::Base
  belongs_to :user, counter_cache: true
  belongs_to :domain, counter_cache: true
  belongs_to :case_note_domain_group
  belongs_to :client

  validates :name, presence: true
  validates :domain, presence: true
  validates :completion_date, presence: true

  scope :completed,  -> { where(completed: true) }
  scope :incomplete, -> { where(completed: false) }
  scope :overdue,    -> { where('completion_date < ?', Date.today) }
  scope :today,      -> { where('completion_date = ?', Date.today) }
  scope :upcoming,   -> { where('completion_date > ?', Date.today) }

  before_save :set_user

  def set_user
    self.user_id = client.user.id if client.user
  end

  def self.of_user(user)
    where(user_id: user.id)
  end

  def self.set_complete
    update_all(completed: true)
  end

  def self.filter(params)
    user = User.find(params[:user_id]) if params[:user_id]
    relation = all
    relation = relation.where(user_id: user.id) if user.present?
    relation
  end

end
