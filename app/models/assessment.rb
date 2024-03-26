class Assessment < ActiveRecord::Base
  belongs_to :client, counter_cache: true
  belongs_to :family, counter_cache: true
  belongs_to :case_conference
  belongs_to :custom_assessment_setting

  has_many :assessment_domains, dependent: :destroy
  has_many :domains, through: :assessment_domains
  has_many :case_notes, dependent: :destroy
  has_many :tasks, as: :taskable, dependent: :destroy
  has_many :goals, dependent: :destroy

  has_one :care_plan, inverse_of: :assessment, dependent: :destroy

  has_paper_trail

  validates :assessment_date, presence: true
  validates :client, presence: true, if: :client_id?
  validate :must_be_enable
  validate :allow_create, :eligible_client_age, if: :new_record?
  validates_uniqueness_of :case_conference_id, on: :create, if: :case_conference_id?

  before_save :populate_domains
  before_save :set_previous_score
  before_save :set_assessment_completed, unless: :completed?
  after_commit :flash_cache

  accepts_nested_attributes_for :assessment_domains

  scope :most_recents, -> { order(created_at: :desc) }
  scope :defaults, -> { where(default: true) }
  scope :customs, -> { where(default: false) }
  scope :completed, -> { where(completed: true) }
  scope :incompleted, -> { where(completed: false) }
  scope :client_risk_assessments, -> { where.not(level_of_risk: nil) }

  scope :not_draft, -> { where(draft: false) }
  scope :draft, -> { where(draft: true) }
  scope :draft_untouch, -> { draft.where(last_auto_save_at: nil) }
  scope :not_untouch_draft, -> { where('draft IS FALSE OR last_auto_save_at IS NOT NULL') }

  default_scope { not_untouch_draft }

  DUE_STATES = ['Due Today', 'Overdue']

  def set_assessment_completed
    return if draft?

    empty_assessment_domains = check_reason_and_score
    if empty_assessment_domains.count.zero?
      self.draft = false
      self.completed = true
      self.completed_date = Time.zone.now
    else
      self.completed = false
      self.completed_date = nil
      true
    end
  end

  def check_reason_and_score
    empty_assessment_domains = []
    setting = Setting.first
    is_ratanak = Organization.ratanak?
    assessment_domains.each do |assessment_domain|
      if is_ratanak
        empty_assessment_domains << assessment_domain if ((setting.disable_required_fields && assessment_domain[:score].nil?) || assessment_domain[:reason].empty?)
      else
        empty_assessment_domains << assessment_domain if ((!setting.disable_required_fields && assessment_domain[:score].nil?) || assessment_domain[:reason].empty?)
      end
    end
    empty_assessment_domains
  end

  def client_risk_assessment?
    level_of_risk.present?
  end

  def self.latest_record
    most_recents.first
  end

  def self.default_latest_record
    defaults.most_recents.first
  end

  def self.custom_latest_record
    customs.most_recents.first
  end

  def initial?(custom_assessment_setting_id = nil)
    if client_id
      if default?
        (self == client.assessments.defaults.most_recents.last) || client.assessments.defaults.count.zero?
      else
        (self == client.assessments.customs.joins(:domains).where(domains: { custom_assessment_setting_id: custom_assessment_setting_id }).most_recents.last) || client.assessments.customs.count.zero?
      end
    elsif family_id
      (self == family.assessments.customs.most_recents.last) || family.assessments.customs.count.zero?
    end
  end

  def latest_record?
    self == client.assessments.latest_record
  end

  def populate_family_domains
    family_domains = Domain.family_custom_csi_domains.presence || Domain.csi_domains
    family_domains.where.not(id: domains.ids).each do |domain|
      assessment_domains.build(domain: domain)
    end
  end

  def basic_info
    "#{created_at.to_date} => #{assessment_domains_score}"
  end

  def assessment_domains_score
    domains.pluck(:name, :score).map { |item| item.join(': ') }.join(', ')
  end

  def assessment_domains_in_order
    assessment_domains.includes(:domain).order('created_at')
  end

  def eligible_client_age
    return false if client.nil?

    eligible = if default?
                 client.eligible_default_csi?
               else
                 custom_assessment_setting_ids = client.assessments.customs.map { |ca| ca.domains.pluck(:custom_assessment_setting_id) }.flatten.uniq
                 CustomAssessmentSetting.where(id: custom_assessment_setting_ids).each do |custom_assessment_setting|
                   client.eligible_custom_csi?(custom_assessment_setting)
                 end
               end
    eligible ? true : errors.add(:base, "Assessment cannot be added due to client's age.")
  end

  def index_of
    Assessment.order(:created_at).where(client_id: client_id).pluck(:id).index(id)
  end

  def parent
    family_id? ? family : client
  end

  private

  def populate_domains
    self.assessment_domains = AssessmentDomainsLoader.call(self) if new_record? && client_id?
  end

  def allow_create
    custom_assessment_setting_id = nil
    if default == false && assessment_domains.any?
      custom_assessment_setting_id = assessment_domains.first.domain&.custom_assessment_setting_id
    end
    errors.add(:base, 'Assessment cannot be created due to either frequency period or previous assessment status') if client.present? && !client.can_create_assessment?(default, custom_assessment_setting_id)
  end

  def must_be_enable
    enable = default? ? Setting.first.enable_default_assessment : Setting.first.enable_custom_assessment
    enable || family ? true : errors.add(:base, 'Assessment tool must be enable in setting')
  end

  def set_previous_score
    if (draft? || new_record?) && !initial?
      if default?
        previous_assessment = parent.assessments.defaults.not_draft.where.not(id: self.id).latest_record
      else
        previous_assessment = parent.assessments.customs.not_draft.where.not(id: self.id).latest_record
      end

      return if previous_assessment.blank?

      previous_assessment.assessment_domains.each do |previous_assessment_domain|
        assessment_domains.each do |assessment_domain|
          assessment_domain.previous_score = previous_assessment_domain.score if assessment_domain.domain_id == previous_assessment_domain.domain_id
        end
      end
    end
  end

  def flash_cache
    Rails.cache.delete([Apartment::Tenant.current, 'User', User.current_user.id, 'assessment_either_overdue_or_due_today']) if User.current_user.present?
    Rails.cache.delete([Apartment::Tenant.current, parent.class.name, 'cached_client_sql_assessment_custom_completed_date', parent.id])
  end
end
