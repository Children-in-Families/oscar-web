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
    user     = User.find(params[:user_id]) if params[:user_id]
    relation = all
    relation = relation.where(user_id: user.id) if user.present?
    relation
  end

  def self.under(user, client)
    where(user_id: user.id, client_id: client.id)
  end

  def self.upcoming_incomplete_tasks
    user_ids = []

    tasks    = incomplete.where(completion_date: Date.tomorrow)
    tasks.group_by(&:user_id).each do |user_id|
      user_ids << user_id.first
    end

    users = User.where(id: user_ids)
    users.each do |user|
      CaseWorkerMailer.tasks_due_tomorrow_of(user).deliver_now
    end
  end
end
