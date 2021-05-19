class Assessment < ActiveRecord::Base
  belongs_to :client, counter_cache: true
  belongs_to :family, counter_cache: true
  belongs_to :case_conference

  has_many :assessment_domains, dependent: :destroy
  has_many :domains,            through:   :assessment_domains
  has_many :case_notes,         dependent: :destroy
  has_many :tasks, as: :taskable, dependent: :destroy
  has_many :goals, dependent: :destroy

  has_one :care_plan, inverse_of: :assessment, dependent: :destroy

  has_paper_trail

  validates :client, presence: true, if: :client_id?
  validate :must_be_enable
  validate :allow_create, :eligible_client_age, if: :new_record?

  before_save :set_previous_score, :set_assessment_completed

  accepts_nested_attributes_for :assessment_domains

  scope :most_recents, -> { order(created_at: :desc) }
  scope :defaults, -> { where(default: true) }
  scope :customs, -> { where(default: false) }
  scope :completed, -> { where(completed: true) }
  scope :incompleted, -> { where(completed: false) }

  DUE_STATES        = ['Due Today', 'Overdue']

  def set_assessment_completed
    empty_assessment_domains = []
    setting = Setting.first
    assessment_domains.each do |assessment_domain|
      empty_assessment_domains << assessment_domain if ((!setting.disable_required_fields && assessment_domain[:score].nil?) || assessment_domain[:reason].empty?)
    end
    if empty_assessment_domains.count.zero?
      self.completed = true
    else
      self.completed = false
      true
    end
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
        self == client.assessments.defaults.most_recents.last || client.assessments.defaults.count.zero?
      else
        self == client.assessments.customs.joins(:domains).where(domains: { custom_assessment_setting_id: custom_assessment_setting_id }).most_recents.last || client.assessments.customs.count.zero?
      end
    elsif family_id
      self == family.assessments.customs.most_recents.last || family.assessments.customs.count.zero?
    end
  end

  def latest_record?
    self == client.assessments.latest_record
  end

  def populate_notes(default, custom_name)
    if custom_name.present?
      custom_assessment_id = CustomAssessmentSetting.find_by(custom_assessment_name: custom_name).id
      domains = default == 'true' ? Domain.csi_domains : CustomAssessmentSetting.find_by(id: custom_assessment_id).domains
    else
      domains = default == 'true' ? Domain.csi_domains : Domain.custom_csi_domains
    end
    domains.each do |domain|
      case_conference_domain = case_conference.case_conference_domains.find_by(domain_id: domain.id) if case_conference
      assessment_domains.build(domain: domain, reason: case_conference_domain&.presenting_problem)
    end
  end

  def repopulate_notes
    case_conference && case_conference.case_conference_domains.each do |case_conference_domain|
      assessment_domain = assessment_domains.find_by(domain_id: case_conference_domain.domain_id)
      if assessment_domain
        assessment_domain.reason = case_conference_domain.presenting_problem
        assessment_domain.save
      end
    end
  end

  def populate_family_domains
    family_domains = Domain.family_custom_csi_domains
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
                custom_assessment_setting_ids = client.assessments.customs.map{|ca| ca.domains.pluck(:custom_assessment_setting_id ) }.flatten.uniq
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

  def allow_create
    errors.add(:base, "Assessment cannot be created due to either frequency period or previous assessment status") if client.present? && !client.can_create_assessment?(default)
  end

  def must_be_enable
    enable = default? || family_id? ? Setting.first.enable_default_assessment : Setting.first.enable_custom_assessment
    enable ? true : errors.add(:base, 'Assessment tool must be enable in setting')
  end

  def set_previous_score
    if new_record? && !initial?
      if default?
        previous_assessment = parent.assessments.defaults.latest_record
      else
        previous_assessment = parent.assessments.customs.latest_record
      end
      previous_assessment.assessment_domains.each do |previous_assessment_domain|
        assessment_domains.each do |assessment_domain|
          assessment_domain.previous_score = previous_assessment_domain.score if assessment_domain.domain_id == previous_assessment_domain.domain_id
        end
      end
    end
  end
end
