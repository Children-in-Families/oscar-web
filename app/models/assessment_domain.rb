class AssessmentDomain < ActiveRecord::Base
  mount_uploaders :attachments, FileUploader

  SCORE_COLORS = {
    has_problem: 'warning',
    not_ideal: 'info',
    good: 'primary',
    critical_problem: 'danger'
  }.freeze

  belongs_to :assessment
  belongs_to :domain
  belongs_to :care_plan

  has_many :goals, dependent: :destroy

  has_paper_trail
  delegate :family, to: :assessment
  delegate :id, to: :family, prefix: :family

  validates :domain, presence: true

  SCORE_COLORS.each do |key, value|
    define_method "#{key}?" do
      score_color_class == value
    end
  end

  def score_color_class
    domain["score_#{score}_color"] || 'default'
  end

  def score_definition
    return '' if score.nil? || score == 0
    domain.send("translate_score_#{score}_definition".to_sym)
  end

  def previous_score_definition
    return '' if previous_score.nil?
    domain.send("translate_score_#{previous_score}_definition".to_sym)
  end

  def previous_score_color_class
    domain["score_#{previous_score}_color"]
  end

  class << self
    def goal_like(values = [])
      where('assessment_domains.goal iLIKE ANY ( array[?] )', values)
    end

    def domain_color_class(domain_id)
      find_by(domain_id: domain_id).score_color_class
    end
  end
end
