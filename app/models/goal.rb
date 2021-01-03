class Goal < ActiveRecord::Base
  belongs_to :domain, counter_cache: true
  belongs_to :assessment_domain
  belongs_to :client
  belongs_to :care_plan

  has_many :tasks, dependent: :destroy

  has_paper_trail

  validates :description, presence: true

  accepts_nested_attributes_for :tasks, reject_if:  proc { |attributes| attributes['name'].blank? &&  attributes['completion_date'].blank? }, allow_destroy: true
end
