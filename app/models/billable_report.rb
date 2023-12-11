class BillableReport < ActiveRecord::Base
  has_paper_trail

  belongs_to :organization

  validates :organization, presence: true
  validates :year, presence: true
  validates :month, presence: true, uniqueness: { scope: [:organization_id, :year] }

  has_many :billable_report_items, dependent: :destroy

  scope :recent, -> { order(year: :desc, month: :desc) }
  scope :by_current_instance, -> { where(organization_id: Organization.current&.id) }

  after_commit :update_organization_info, unless: :destroyed?

  def date
    Date.new(year, month)
  end

  def update_organization_info
    update_columns(
      organization_name: organization.full_name,
      organization_short_name: organization.short_name
    )
  end
end
