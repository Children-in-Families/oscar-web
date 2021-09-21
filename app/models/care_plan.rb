class CarePlan < ActiveRecord::Base
  belongs_to :client
  belongs_to :assessment
  belongs_to :family, counter_cache: true

  has_many  :assessment_domains, dependent: :destroy
  has_many  :goals, dependent: :destroy

  has_paper_trail

  accepts_nested_attributes_for :goals, reject_if:  proc { |attributes| attributes['description'].blank? }, allow_destroy: true
  accepts_nested_attributes_for :assessment_domains

  validates_uniqueness_of :assessment_id, on: :create

  after_save :complete_previouse_tasks

  scope :completed, -> { where(completed: true) }
  scope :incompleted, -> { where(completed: false) }

  def parent
    family_id? ? family : client
  end

  def is_goals_tasks_exist?(domain_id)
    goals.find_by_domain(domain_id).present? ? goals.find_by_domain(domain_id).first.tasks.incomplete.upcoming.present? : false
  end

  private

  def complete_previouse_tasks
    previous_ids = goals.joins(:tasks).select('tasks.previous_id').map(&:previous_id).reject(&:blank?)
    Task.where(id: previous_ids, completed: false).update_all(completed: true, completion_date: Time.now) if previous_ids.present?
  end

end
