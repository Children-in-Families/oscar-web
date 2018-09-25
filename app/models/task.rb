class Task < ActiveRecord::Base
  belongs_to :domain, counter_cache: true
  belongs_to :case_note_domain_group
  belongs_to :client
  belongs_to :user

  has_paper_trail

  validates :name, presence: true
  validates :domain, presence: true
  validates :completion_date, presence: true

  scope :completed,                       -> { where(completed: true) }
  scope :incomplete,                      -> { where(completed: false) }
  scope :overdue,                         -> { where('completion_date < ?', Date.today) }
  scope :today,                           -> { where('completion_date = ?', Date.today) }
  scope :upcoming,                        -> { where('completion_date > ?', Date.today) }
  scope :upcoming_within_three_months,    -> { where(completion_date: Date.tomorrow..3.months.from_now) }
  scope :by_case_note,                    -> { where(relation: 'case_note') }
  scope :by_assessment,                   -> { where(relation: 'assessment') }


  scope :overdue_incomplete, -> { incomplete.overdue }
  scope :today_incomplete,   -> { incomplete.today }
  scope :by_domain_id,       ->(value) { where('domain_id = ?', value) }
  scope :overdue_incomplete_ordered, -> { overdue_incomplete.order('completion_date ASC') }
  scope :exclude_exited_ngo_clients, -> { where(client_id: Client.active_accepted_status.ids) }

  after_save :create_task_history

  def self.of_user(user)
    where(user_id: user.id)
  end

  def self.set_complete
    update_all(completed: true)
  end

  def self.filter(params)
    user     = User.find(params[:user_id]) if params[:user_id]
    relation = all
    relation = relation.of_user(user) if user.present?
    relation
  end

  def self.under(user, client)
    of_user(user).where(client_id: client.id)
  end

  def self.upcoming_incomplete_tasks
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      tasks    = incomplete.where(completion_date: Date.tomorrow).exclude_exited_ngo_clients
      user_ids = tasks.map(&:user_id).flatten.uniq
      users    = User.non_devs.non_locked.where(id: user_ids)
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
