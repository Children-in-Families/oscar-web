class Domain < ActiveRecord::Base
  TYPES = [['Client', 'client'], ['Family', 'family'], ['Community', 'community']].freeze
  belongs_to :domain_group, counter_cache: true

  has_many   :assessment_domains, dependent: :restrict_with_error
  has_many   :assessments, through: :assessment_domains
  has_many   :tasks, dependent: :restrict_with_error
  has_many   :domain_program_streams, dependent: :restrict_with_error
  has_many   :program_streams, through: :domain_program_streams

  belongs_to :custom_assessment_setting, required: false

  has_paper_trail

  validates :domain_group, :domain_type, presence: true
  validates :name, :identity, presence: true, uniqueness: { case_sensitive: false, scope: :custom_assessment_setting}
  validates :custom_assessment_setting_id, presence: true, if: :custom_domain?

  default_scope { order('domain_group_id ASC, name ASC') }

  scope :assessment_domains_by_assessment_id, ->(id) { joins(:assessment_domains).where('assessment_domains.assessment_id = ?', id) }
  scope :order_by_identity, -> { order(:identity) }
  scope :csi_domains, -> { where(custom_domain: false) }
  scope :custom_csi_domains, -> { where(custom_domain: true) }

  delegate :custom_assessment_name, to: :custom_assessment_setting, prefix: false, allow_nil: true
  enum domain_score_colors: { danger: 'Red', warning: 'Yellow', success: 'Blue', primary: 'Green' }

  def convert_identity
    identity.downcase.parameterize('_')
  end

  def translate_description
    I18n.locale == :en ? description : local_description
  end

  (1..10).each do |number|
    define_method "translate_score_#{number}_definition" do
      I18n.locale == :en ? send("score_#{number}_definition".to_sym) : send("score_#{number}_local_definition".to_sym)
    end
  end
end
