class Domain < ActiveRecord::Base
  belongs_to :domain_group, counter_cache: true

  has_many   :assessment_domains
  has_many   :tasks

  validates :domain_group, presence: true
  validates :identity, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true

  default_scope { order('domain_group_id ASC, name ASC') }

  scope :assessment_domains_by_assessment_id, -> (id) { joins(:assessment_domains).where('assessment_domains.assessment_id = ?', id) }

  enum domain_score_colors: { danger: 'Red', warning: 'Yellow', info: 'Blue', primary: 'Green' }
end
