class CarePlan < ActiveRecord::Base
  belongs_to :client
  belongs_to :assessment
  belongs_to :family, counter_cache: true

  has_many  :assessment_domains, dependent: :destroy
  has_many  :goals, dependent: :destroy

  accepts_nested_attributes_for :goals, reject_if:  proc { |attributes| attributes['description'].blank? }, allow_destroy: true
  accepts_nested_attributes_for :assessment_domains
  has_paper_trail

  scope :completed, -> { where(completed: true) }
  scope :incompleted, -> { where(completed: false) }

  def parent
    family_id? ? family : client
  end
end
