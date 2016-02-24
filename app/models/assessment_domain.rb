class AssessmentDomain < ActiveRecord::Base
  belongs_to :assessment
  belongs_to :domain

  validates :domain_id, presence: true

  default_scope { joins(:domain).order('domains.name ASC') }

  OUTCOME_DOMAIN_NAMES = ['1A', '3A', '3B', '6B']

  def has_critical_problem?
    score == 1 || (score == 2 && OUTCOME_DOMAIN_NAMES.include?(domain.name))
  end

  def has_problem?
    (score == 2 && !OUTCOME_DOMAIN_NAMES.include?(domain.name)) || (score == 3 && OUTCOME_DOMAIN_NAMES.include?(domain.name))
  end

  def not_ideal?
    score == 3 && !OUTCOME_DOMAIN_NAMES.include?(domain.name)
  end

  def good?
    score == 4
  end

  def score_color_class
    if has_critical_problem?
      'danger'
    elsif has_problem?
      'warning'
    elsif not_ideal?
      'info'
    else
      'success'
    end
  end

  def previous_score_color_class
    if previous_score == 1 || (previous_score == 2 && OUTCOME_DOMAIN_NAMES.include?(domain.name))
      'danger'
    elsif (previous_score == 2 && !OUTCOME_DOMAIN_NAMES.include?(domain.name)) || (previous_score == 3 && OUTCOME_DOMAIN_NAMES.include?(domain.name))
      'warning'
    elsif previous_score == 3 && !OUTCOME_DOMAIN_NAMES.include?(domain.name)
      'info'
    else
      'success'
    end
  end
end
