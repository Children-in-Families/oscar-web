class CaseConference < ActiveRecord::Base
  mount_uploader :attachments, ImageUploader

  belongs_to :client

  has_many :case_conference_domains, dependent: :destroy
  has_many :domains, through: :case_conference_domains
  has_many :case_conference_users, dependent: :destroy
  has_many :users, through: :case_conference_users

  accepts_nested_attributes_for :case_conference_domains
  scope :most_recents, -> { order(created_at: :desc) }

  def populate_presenting_problems
    domains = Domain.csi_domains
    domains.each do |domain|
      case_conference_domains.build(domain: domain)
    end
  end

  def initial?
    self == client.case_conferences.most_recents.last || client.case_conferences.count.zero?
  end
end
