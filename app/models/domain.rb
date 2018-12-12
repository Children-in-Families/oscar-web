class Domain < ActiveRecord::Base
  belongs_to :domain_group, counter_cache: true

  has_many   :assessment_domains, dependent: :restrict_with_error
  has_many   :assessments, through: :assessment_domains
  has_many   :tasks, dependent: :restrict_with_error
  has_many   :domain_program_streams, dependent: :restrict_with_error
  has_many   :program_streams, through: :domain_program_streams

  has_paper_trail

  validates :domain_group, presence: true
  validates :name, :identity, presence: true, uniqueness: { case_sensitive: false, scope: :custom_domain}

  default_scope { order('domain_group_id ASC, name ASC') }

  scope :assessment_domains_by_assessment_id, ->(id) { joins(:assessment_domains).where('assessment_domains.assessment_id = ?', id) }
  scope :order_by_identity, -> { order(:identity) }
  scope :csi_domains, -> { where(custom_domain: false) }
  scope :custom_csi_domains, -> { where(custom_domain: true) }

  enum domain_score_colors: { danger: 'Red', warning: 'Yellow', success: 'Blue', primary: 'Green' }

  def convert_identity
    identity.downcase.parameterize('_')
  end
end
