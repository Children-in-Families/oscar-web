class CaseConference < ActiveRecord::Base
  mount_uploaders :attachments, ConsentFormUploader
  has_paper_trail

  belongs_to :client

  has_one :assessment, inverse_of: :case_conference, dependent: :destroy

  has_many :case_conference_domains, dependent: :destroy
  has_many :domains, through: :case_conference_domains
  has_many :case_conference_users, dependent: :destroy
  has_many :users, through: :case_conference_users

  validates :meeting_date, presence: true
  validates :user_ids, presence: true

  accepts_nested_attributes_for :case_conference_domains
  scope :most_recents, -> { order(meeting_date: :desc) }
  scope :order_by_meeting_date, -> { order(:meeting_date) }
  scope :latest_record, -> { most_recents.first }

  def populate_presenting_problems
    domains = Domain.csi_domains.order(:name)
    domains.each do |domain|
      if persisted?
        case_conference_domains.build(domain: domain).each do |case_conference_domain|
          case_conference_domain.populate_addressed_issue
        end
      else
        case_conference_domains.build(domain: domain)
      end
    end
  end

  def initial?
    self == client.case_conferences.most_recents.last || client.case_conferences.count.zero?
  end

  def index_of
    CaseConference.order(:created_at).where(client_id: client_id).pluck(:id).index(id)
  end

  def case_conference_order_by_domain_name
    case_conference_domains.joins(:domain).order('domains.name').presence || case_conference_domains
  end

  def can_create_case_conference?
    setting = Setting.first
    assessment_period = setting.max_assessment
    assessment_frequency = setting.assessment_frequency
    assessment_min_max = assessment_period.send(assessment_frequency)
    (Date.today >= client.next_case_conference_date(user_activated_date = nil))
  end
end
