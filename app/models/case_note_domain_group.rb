class CaseNoteDomainGroup < ActiveRecord::Base
  belongs_to :case_note
  belongs_to :domain_group

  has_many :tasks

  has_paper_trail

  validates :domain_group, presence: true

  default_scope { order(:domain_group_id) }

  def completed_tasks
    tasks.completed
  end
end
