class Goal < ActiveRecord::Base
  belongs_to :domain, counter_cache: true
  belongs_to :assessment_domain
  belongs_to :client
  belongs_to :care_plan
  belongs_to :family

  has_many :tasks, dependent: :nullify

  has_paper_trail

  validates :description, presence: true

  accepts_nested_attributes_for :tasks, reject_if:  proc { |attributes| attributes['name'].blank? &&  attributes['expected_date'].blank? }, allow_destroy: true
end
