class CaseNote < ActiveRecord::Base
  INTERACTION_TYPE = ['Visit', 'Non face to face', '3rd Party', 'Other'].freeze

  belongs_to :client
  belongs_to :assessment
  has_many   :case_note_domain_groups, dependent: :destroy
  has_many   :domain_groups, through: :case_note_domain_groups

  validates :meeting_date, :attendee, presence: true
  validates :interaction_type, presence: true, inclusion: { in: INTERACTION_TYPE }

  has_paper_trail

  accepts_nested_attributes_for :case_note_domain_groups

  scope :most_recents, -> { order(created_at: :desc) }
  scope :no_case_note_in, ->(value) { where('meeting_date <= ? AND id = (SELECT MAX(cn.id) FROM CASE_NOTES cn where CASE_NOTES.client_id = cn.client_id)', value) }

  before_create :set_assessment

  def populate_notes
    DomainGroup.all.each do |dg|
      case_note_domain_groups.build(domain_group_id: dg.id)
    end
  end

  def complete_tasks(params)
    params.each do |_index, param|
      case_note_domain_group = case_note_domain_groups.find_by(domain_group_id: param[:domain_group_id])
      task_ids = param[:task_ids] || []
      case_note_domain_group.tasks = Task.where(id: task_ids)
      case_note_domain_group.tasks.set_complete
      case_note_domain_group.save
    end
  end

  def self.latest_record
    order(meeting_date: :desc).first
  end

  private

  def set_assessment
    self.assessment = client.assessments.latest_record
  end
end
