class Task < ActiveRecord::Base
  belongs_to :domain, counter_cache: true
  belongs_to :case_note_domain_group
  belongs_to :client
  belongs_to :user
  belongs_to :taskable, polymorphic: true, required: false
  belongs_to :family
  belongs_to :goal, required: false
  belongs_to :completed_by, class_name: 'User', foreign_key: 'completed_by_id'
  has_one :calendar, dependent: :nullify

  has_many :service_delivery_tasks, dependent: :destroy
  has_many :service_deliveries, through: :service_delivery_tasks
  has_many :task_progress_notes, dependent: :destroy

  has_paper_trail
  acts_as_paranoid double_tap_destroys_fully: false

  validates :name, presence: true
  validates :domain, presence: true, if: -> { taskable_type != 'ScreeningAssessment' && taskable_type != 'RiskAssessment' }
  validates :expected_date, presence: true

  accepts_nested_attributes_for :task_progress_notes, reject_if: proc { |attribute| attribute['progress_note'].blank? }, allow_destroy: true

  scope :completed, -> { where(completed: true) }
  scope :incomplete, -> { where(completed: false) }
  scope :overdue, -> { where('expected_date < ?', Date.today) }
  scope :today, -> { where('expected_date = ?', Date.today) }
  scope :upcoming, -> { where('expected_date > ?', Date.today) }

  scope :overdue_completed_date, -> { where('completion_date < ?', Date.today) }
  scope :today_completed_date, -> { where('completion_date = ?', Date.today) }
  scope :upcoming_completed_date, -> { where('completion_date > ?', Date.today) }

  scope :the_latest, -> { incomplete.where('DATE(created_at) = ?', Time.zone.now) }
  scope :upcoming_within_three_months, -> { where(expected_date: Date.tomorrow..3.months.from_now) }
  scope :by_case_note, -> { where(relation: 'case_note') }
  scope :by_assessment, -> { where(relation: 'assessment') }

  scope :overdue_incomplete, -> { incomplete.overdue }
  scope :today_incomplete, -> { incomplete.today }
  scope :by_domain_id, -> (value) { where('domain_id = ?', value) }
  scope :overdue_incomplete_ordered, -> { overdue_incomplete.order('expected_date ASC') }
  scope :exclude_exited_ngo_clients, -> { where(client_id: Client.active_accepted_status.ids) }

  after_save :create_task_history
  after_commit :save_parent_parent_id, :on => [:create, :update]
  after_commit :delete_tasks_from_google_calendar, if: :completed?
  after_commit :flash_cache

  def self.of_user(user)
    where(user_id: user.id)
  end

  def self.set_complete(case_note, completed_by_id)
    update_all(completed: true, completion_date: case_note.meeting_date, taskable_id: case_note.id, taskable_type: case_note.class.to_s, completed_by_id: completed_by_id)
  end

  def self.filter(params)
    user = User.find(params[:user_id]) if params[:user_id]
    relation = all
    relation = relation.of_user(user) if user.present?
    relation
  end

  def self.under(user, client)
    of_user(user).where(client_id: client.id)
  end

  def self.upcoming_incomplete_tasks
    Organization.oscar.without_shared.each do |org|
      Organization.switch_to org.short_name
      tasks = with_deleted.incomplete.where(expected_date: Date.tomorrow).exclude_exited_ngo_clients
      user_ids = tasks.map(&:user_id).flatten.uniq
      users = User.non_devs.non_locked.where(id: user_ids)
      users.each do |user|
        CaseWorkerMailer.tasks_due_tomorrow_of(user).deliver_now
      end
    end
  end

  def self.by_case_note_domain_group(cdg)
    cdg_tasks = cdg.tasks.with_deleted.incomplete.ids
    incomplete = self.incomplete.ids
    ids = cdg_tasks + incomplete
    where(id: ids)
  end

  def create_task_history
    # TaskHistory.initial(self)
  end

  def create_service_delivery_tasks(the_service_delivery_task_ids)
    the_service_delivery_task_ids.each do |service_delivery_id|
      service_delivery_tasks.create(service_delivery_id: service_delivery_id)
    end
  end

  def map_service_deliveries
    service_deliveries.map(&:name)
  end

  def who_complete_the_task
    completed_by&.name
  end

  def populate_task_progress_notes
    task_progress_notes.build
  end

  private

  def save_parent_parent_id
    return if taskable_type == 'ScreeningAssessment' || taskable_type == 'RiskAssessment'
    parent_family_id = goal&.care_plan&.family_id || taskable&.family_id
    parent_client_id = goal&.care_plan&.client_id || taskable&.client_id

    update_columns(family_id: parent_family_id, client_id: parent_client_id)
  end

  def delete_tasks_from_google_calendar
  end

  def flash_cache
    Rails.cache.delete([Apartment::Tenant.current, 'User', 'Client', client.id, 'tasks'])
  end
end
