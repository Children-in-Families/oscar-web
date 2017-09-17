class Task < ActiveRecord::Base
  belongs_to :domain, counter_cache: true
  belongs_to :case_note_domain_group
  belongs_to :client

  has_many :case_worker_tasks, dependent: :destroy
  has_many :users, through: :case_worker_tasks

  has_paper_trail

  validates :name, presence: true
  validates :domain, presence: true
  validates :completion_date, presence: true
  # validates :user_ids, presence: true

  scope :completed,  -> { where(completed: true) }
  scope :incomplete, -> { where(completed: false) }
  scope :overdue,    -> { where('completion_date < ?', Date.today) }
  scope :today,      -> { where('completion_date = ?', Date.today) }
  scope :upcoming,   -> { where('completion_date > ?', Date.today) }

  scope :overdue_incomplete, -> { incomplete.overdue }
  scope :today_incomplete,   -> { incomplete.today }
  scope :by_domain_id,       ->(value) { where('domain_id = ?', value) }

  scope :overdue_incomplete_ordered, -> { overdue_incomplete.order('completion_date ASC') }

  after_save :set_users, :create_task_history

  def set_users
    client.users.map { |user| CaseWorkerTask.find_or_create_by(task_id: id, user_id: user.id) }
  end

  def self.of_user(user)
    joins(:case_worker_tasks).where(case_worker_tasks: { user_id: user.id })
  end

  def self.set_complete
    update_all(completed: true)
  end

  def self.filter(params)
    user     = User.find(params[:user_id]) if params[:user_id]
    relation = all
    relation = relation.joins(:case_worker_tasks).where(case_worker_tasks: { user_id: user.id }) if user.present?
    relation
  end

  def self.under(user, client)
    joins(:case_worker_tasks).where(case_worker_tasks: { user_id: user.id }).where(client_id: client.id)
  end

  def self.upcoming_incomplete_tasks
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      user_ids = incomplete.where(completion_date: Date.tomorrow).map(&:user_ids).flatten.uniq
      users    = User.non_devs.where(id: user_ids)
      users.each do |user|
        CaseWorkerMailer.tasks_due_tomorrow_of(user).deliver_now
      end
    end
  end

  def self.by_case_note_domain_group(cdg)
    cdg_tasks  = cdg.tasks.ids
    incomplete = self.incomplete.ids
    ids        = cdg_tasks + incomplete
    where(id: ids)
  end

  def create_task_history
    TaskHistory.initial(self)
  end
end
