class Assessment < ActiveRecord::Base

  belongs_to :client, counter_cache: true

  has_many :assessment_domains, dependent: :destroy
  has_many :domains,            through:   :assessment_domains
  has_many :case_notes,         dependent: :destroy

  has_paper_trail

  validates :client, presence: true
  validate :must_be_six_month_period, if: :new_record?
  validate :only_latest_record_can_be_updated

  before_save :set_previous_score

  accepts_nested_attributes_for :assessment_domains

  scope :most_recents, -> { order(created_at: :desc) }

  scope :today_dues, -> { where('DATE(created_at) = ?', (Date.today - 6.months).in_time_zone('Bangkok')) }
  scope :over_dues, -> { where('created_at < ?', maximum_created_at) }

  def self.latest_record
    most_recents.first
  end

  def self.today_dues_of(clients)
    today_dues.where(client: clients)
  end

  def self.over_dues_of(clients)
    over_dues.where(client: clients)
  end

  def self.maximum_created_at
    return Date.today.in_time_zone('Bangkok') unless any?
    (last.created_at + 6.months).in_time_zone('Bangkok')
  end

  #USE COUNTER CACHE ON CLIENT ASSESSMENT COUNT
  def initial?
    self == client.assessments.most_recents.last || client.assessments.count.zero?
  end

  def latest_record?
    self == client.assessments.latest_record
  end

  def populate_notes
    Domain.all.each do |domain|
      assessment_domains.build(domain: domain)
    end
  end

  def basic_info
    "#{created_at.to_date} => #{assessment_domains_score}"
  end

  def assessment_domains_score
    # assessment_domains.map { |assessment_domain| "#{assessment_domain.domain.name}: #{assessment_domain.score}" }.join(', ')
    domains.pluck(:name, :score).map { |item| item.join(': ') }.join(', ')
  end

  private

  def must_be_six_month_period
    if new_record? && client.present? && !client.can_create_assessment?
      errors.add(:base, 'Assessment cannot be created before 6 months')
    end
  end

  def only_latest_record_can_be_updated
    if persisted? && !latest_record?
      errors.add(:base, 'Assessment cannot be updated')
    end
  end

  def set_previous_score
    if new_record? && !initial?
      previous_assessment = client.assessments.latest_record
      previous_assessment.assessment_domains.each do |previous_assessment_domain|
        assessment_domains.each do |assessment_domain|
          if assessment_domain.domain_id == previous_assessment_domain.domain_id
            assessment_domain.previous_score = previous_assessment_domain.score
          end
        end
      end
    end
  end
end
