class BillableReport < ActiveRecord::Base
  has_paper_trail

  belongs_to :organization

  validates :organization, presence: true
  validates :year, presence: true
  validates :month, presence: true, uniqueness: { scope: [:organization_id, :year] }

  has_many :billable_items, class_name: 'PaperTrail::Version', foreign_key: :billable_report_id
  has_many :billable_clients, -> { where(item_type: 'Client') }, class_name: 'PaperTrail::Version', foreign_key: :billable_report_id
  has_many :billable_families, -> { where(item_type: 'Family') }, class_name: 'PaperTrail::Version', foreign_key: :billable_report_id
end
