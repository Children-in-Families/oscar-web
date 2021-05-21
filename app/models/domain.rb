class Domain < ActiveRecord::Base
  TYPES = [['Client', 'client'], ['Family', 'family'], ['Community', 'community']].freeze
  belongs_to :domain_group, counter_cache: true

  has_many   :assessment_domains, dependent: :restrict_with_error
  has_many   :assessments, through: :assessment_domains
  has_many   :tasks, dependent: :restrict_with_error
  has_many   :domain_program_streams, dependent: :restrict_with_error
  has_many   :program_streams, through: :domain_program_streams
  has_many :case_conference_domains, dependent: :destroy
  has_many :case_conferences, through: :case_conference_domains

  belongs_to :custom_assessment_setting, required: false

  has_paper_trail

  validates :domain_group, :domain_type, :identity, presence: true
  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: [:identity, :custom_assessment_setting_id, :domain_type] }
  validates :custom_assessment_setting_id, presence: true, if: -> { custom_domain? && domain_type_client? }
  validates :domain_type, inclusion: { in: TYPES.map(&:last) }, allow_blank: true

  default_scope { order('domain_group_id ASC, name ASC') }

  scope :assessment_domains_by_assessment_id, ->(ass_id) { joins(:assessment_domains).where('assessment_domains.assessment_id = ?', ass_id) }
  scope :order_by_identity, -> { order(:identity) }
  scope :client_domians, -> { where(domain_type: 'client') }
  scope :csi_domains, -> { where(domain_type: 'client', custom_domain: false) }
  scope :custom_csi_domains, -> { where(domain_type: 'client', custom_domain: true) }
  scope :custom_csi_domain_setting, ->(cas_id) { where(domain_type: 'client', custom_domain: true, custom_assessment_setting_id: cas_id) }
  scope :custom_domains, -> { where(custom_domain: true) }
  scope :family_custom_csi_domains, -> { where(domain_type: 'family', custom_domain: true) }

  delegate :custom_assessment_name, to: :custom_assessment_setting, prefix: false, allow_nil: true
  enum domain_score_colors: { danger: 'Red', warning: 'Yellow', success: 'Blue', primary: 'Green' }

  def convert_identity
    identity.downcase.parameterize('_')
  end

  def convert_custom_identity
    "custom_#{identity.downcase.parameterize.underscore}"
  end

  def translate_description
    I18n.locale == :en ? description : local_description
  end

  (1..10).each do |number|
    define_method "translate_score_#{number}_definition" do
      I18n.locale == :en ? send("score_#{number}_definition".to_sym) : send("score_#{number}_local_definition".to_sym)
    end
  end

  def domain_type_client?
    domain_type == 'client'
  end
end
