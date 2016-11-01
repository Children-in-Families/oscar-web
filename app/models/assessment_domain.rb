class AssessmentDomain < ActiveRecord::Base

  SCORE_COLORS = { has_problem: 'warning', not_ideal: 'info', good: 'success',
                    critical_problem: 'danger' }

  belongs_to :assessment
  belongs_to :domain

  has_and_belongs_to_many :progress_notes

  validates :domain_id, presence: true
  validates :score, presence: true
  validates :reason, presence: true
  validates :domain, presence: true
  validates :goal, presence: true

  default_scope { joins(:domain).order('domains.name ASC') }
  scope :goal_like, -> (values) { where('LOWER(assessment_domains.goal) ILIKE ANY ( array[?] )', values.map { |val| "%#{val.downcase}%" }) }

  SCORE_COLORS.each do |key, value|
    define_method "#{key}?" do
      score_color_class == value
    end
  end

  def self.domain_color_class(domain_id)
    find_by(domain_id: domain_id).score_color_class
  end


  def score_color_class
    domain["score_#{score}_color"]
  end

  def previous_score_color_class
    domain["score_#{previous_score}_color"]
  end
end
