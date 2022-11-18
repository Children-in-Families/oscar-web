class Goal < ApplicationRecord
  belongs_to :domain, counter_cache: true
  belongs_to :assessment_domain
  belongs_to :client
  belongs_to :care_plan
  belongs_to :family

  has_many :tasks, dependent: :destroy

  has_paper_trail

  validates :description, presence: true

  before_destroy :delete_tasks

  accepts_nested_attributes_for :tasks, reject_if:  proc { |attributes| attributes['name'].blank? && attributes['expected_date'].blank? }, allow_destroy: true
  scope :find_by_domain, ->(domain_id) { joins(:assessment_domain).where(assessment_domains: { domain_id: domain_id }) }

  private

  def delete_tasks
    tasks.with_deleted.each(&:destroy_fully!)
  end
end
