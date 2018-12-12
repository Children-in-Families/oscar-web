class Assessment < ActiveRecord::Base
  belongs_to :client, counter_cache: true

  has_many :assessment_domains, dependent: :destroy
  has_many :domains,            through:   :assessment_domains
  has_many :case_notes,         dependent: :destroy

  has_paper_trail

  validates :client, presence: true
  validate :must_be_enable
  # validate :must_be_min_assessment_period, :eligible_client_age, :check_previous_assessment_status, if: :new_record?
  validate :allow_create, :eligible_client_age, if: :new_record?


  before_save :set_previous_score, :set_assessment_completed

  accepts_nested_attributes_for :assessment_domains

  scope :most_recents, -> { order(created_at: :desc) }
  scope :defaults, -> { where(default: true) }
  scope :customs, -> { where(default: false) }

  DUE_STATES        = ['Due Today', 'Overdue']

  def set_assessment_completed
    empty_assessment_domains = []
    assessment_domains.each do |assessment_domain|
      empty_assessment_domains << assessment_domain if (assessment_domain[:goal].empty? && assessment_domain[:goal_required] == true) || assessment_domain[:score].nil? || assessment_domain[:reason].empty?
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

  def initial?
    if default?
      self == client.assessments.defaults.most_recents.last || client.assessments.defaults.count.zero?
    else
      self == client.assessments.customs.most_recents.last || client.assessments.customs.count.zero?
    end
  end

  def latest_record?
    self == client.assessments.latest_record
  end

  def populate_notes(default)
    domains = default == 'true' ? Domain.csi_domains : Domain.custom_csi_domains
    domains.each do |domain|
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
    assessment_domains.order('created_at')
  end

  def eligible_client_age
    return false if client.nil?

    eligible = default? ? client.eligible_default_csi? : client.eligible_custom_csi?
    eligible ? true : errors.add(:base, "Assessment cannot be added due to client's age.")
  end

  def index_of
    Assessment.order(:created_at).where(client_id: client_id).pluck(:id).index(id)
  end

  private

  def allow_create
    errors.add(:base, "Assessment cannot be created due to either frequency period or previous assessment status") if client.present? && !client.can_create_assessment?(default)
  end

  # merged to allow_create
  # def must_be_min_assessment_period
  #   # period = Setting.first.try(:min_assessment) || 3
  #   period = 3
  #   errors.add(:base, "Assessment cannot be created before #{period} months") if new_record? && client.present? && !client.can_create_assessment?(default)
  # end

  # def only_latest_record_can_be_updated
  #   errors.add(:base, 'Assessment cannot be updated') if persisted? && !latest_record?
  # end

  def must_be_enable
    enable = default? ? Setting.first.enable_default_assessment : Setting.first.enable_custom_assessment
    enable ? true : errors.add(:base, 'Assessment tool must be enable in setting')
  end

  def set_previous_score
    if new_record? && !initial?
      if default?
        previous_assessment = client.assessments.defaults.latest_record
      else
        previous_assessment = client.assessments.customs.latest_record
      end
      previous_assessment.assessment_domains.each do |previous_assessment_domain|
        assessment_domains.each do |assessment_domain|
          assessment_domain.previous_score = previous_assessment_domain.score if assessment_domain.domain_id == previous_assessment_domain.domain_id
        end
      end
    end
  end

  # merged to allow_create
  # def check_previous_assessment_status
  #   if default?
  #     errors.add(:base, 'Please complete the previous assessment before creating another one.') if client.assessments.defaults.present? && client.assessments.defaults.latest_record.completed == false
  #   else
  #     errors.add(:base, 'Please complete the previous assessment before creating another one.') if client.assessments.customs.present? && client.assessments.customs.latest_record.completed == false
  #   end
  # end
end
