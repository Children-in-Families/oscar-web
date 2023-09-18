class BillableReport < ActiveRecord::Base
  has_paper_trail

  belongs_to :organization

  validates :organization, presence: true
  validates :year, presence: true
  validates :month, presence: true, uniqueness: { scope: [:organization_id, :year] }

  has_many :billable_report_items, dependent: :destroy
end
