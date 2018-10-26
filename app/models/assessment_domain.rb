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
  has_and_belongs_to_many :progress_notes

  has_paper_trail

  # validates :score, :reason, :domain, :goal, presence: true
  validates :domain, presence: true

  SCORE_COLORS.each do |key, value|
    define_method "#{key}?" do
      score_color_class == value
    end
  end

  def score_color_class
    domain["score_#{score}_color"]
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
