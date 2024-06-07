class CarePlan < ActiveRecord::Base
  belongs_to :client
  belongs_to :assessment
  belongs_to :family, counter_cache: true

  has_many :assessment_domains, dependent: :destroy
  has_many :goals, dependent: :destroy

  has_paper_trail

  accepts_nested_attributes_for :goals, reject_if: proc { |attributes| attributes['description'].blank? }, allow_destroy: true
  accepts_nested_attributes_for :assessment_domains

  validates_uniqueness_of :assessment_id, on: :create
  validates_presence_of :care_plan_date

  after_save :set_care_plan_completed, :complete_previouse_tasks

  scope :completed, -> { where(completed: true) }
  scope :incompleted, -> { where(completed: false) }

  def parent
    family_id? ? family : client
  end

  def is_goals_tasks_exist?(domain_id)
    goals.find_by_domain(domain_id).present? ? goals.find_by_domain(domain_id).first.tasks.incomplete.upcoming.any? : false
  end

  private

  def complete_previouse_tasks
    previous_ids = goals.joins(:tasks).select('tasks.previous_id').map(&:previous_id).reject(&:blank?)
    Task.where(id: previous_ids, completed: false).update_all(completed: true, completion_date: Time.now) if previous_ids.present?
  end

  def set_care_plan_completed
    return if goals.empty? && !Setting.first.disable_required_fields?

    required_assessment_domains = []
    assessment.assessment_domains.each do |assessment_domain|
      required_assessment_domains << assessment_domain if domain_color_required?(assessment_domain)
    end
    required_assessment_domain_ids = required_assessment_domains.map(&:id)

    if Setting.first.disable_required_fields? || (goals.pluck(:assessment_domain_id) & required_assessment_domain_ids).sort == required_assessment_domain_ids.sort
      update_columns(completed: true)
    else
      update_columns(completed: false)
    end
  end

  def domain_color_required?(assessment_domain)
    return false if assessment_domain[:score].nil? || assessment_domain.domain.nil?

    assessment_domain.domain.send("score_#{assessment_domain[:score]}_color").present? && assessment_domain.domain.send("score_#{assessment_domain[:score]}_color") != 'primary'
  end
end
