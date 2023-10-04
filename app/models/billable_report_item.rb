class BillableReportItem < ActiveRecord::Base
  belongs_to :billable, polymorphic: true
  belongs_to :billable_report
  belongs_to :version, class_name: "PaperTrail::Version"

  validates :billable_status, presence: true
end
