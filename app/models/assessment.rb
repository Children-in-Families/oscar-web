class Assessment < ActiveRecord::Base
  belongs_to :client

  has_many :assessment_domains, dependent: :destroy
  has_many :domains,            through:   :assessment_domains
  has_many :case_notes,         dependent: :destroy

  validates :client_id, presence: true

  accepts_nested_attributes_for :assessment_domains

  scope :most_recents, -> { order(created_at: :desc) }

  validate :must_be_six_month_period
  validate :only_latest_record_can_be_updated

  before_save :set_previous_score

  def self.latest_record
    most_recents.first
  end

  def initial?
    self == self.client.assessments.most_recents.last || self.client.assessments.count.zero?
  end

  def latest_record?
    self == self.class.latest_record
    # TODO: Remove hard coded(always returns true!!!)
    true
  end

  def populate_notes
    Domain.all.each do |domain|
      assessment_domains.build(domain_id: domain.id)
    end
  end

  private

  def must_be_six_month_period
    errors.add(:base, 'Assessment cannot be created before 6 months') unless self.client.can_create_assessment?
  end

  def only_latest_record_can_be_updated
    if persisted?
      errors.add(:base, 'Assessment cannot be updated') unless latest_record?
    end
  end

  def set_previous_score
    if new_record? && !initial?
      previous_assessment = self.class.latest_record
      previous_assessment.assessment_domains.each do |previous_assessment_domain|
        assessment_domains.each do |assessment_domain|
          if assessment_domain.domain_id == previous_assessment_domain.domain_id
            assessment_domain.previous_score = previous_assessment_domain.score
          end
        end
      end
    end
  end
end
