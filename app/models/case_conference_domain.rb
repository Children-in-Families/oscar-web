class CaseConferenceDomain < ActiveRecord::Base
  belongs_to :domain
  belongs_to :case_conference

  has_many :case_conference_addressed_issues

  validates :presenting_problem, presence: true

  accepts_nested_attributes_for :case_conference_addressed_issues, reject_if: proc { |attributes| attributes['title'].blank? }, allow_destroy: true

  def populate_addressed_issue
    case_conference_addressed_issues.build
  end
end
