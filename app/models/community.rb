class Community < ActiveRecord::Base
  acts_as_paranoid

  mount_uploaders :documents, FileUploader

  delegate :name, to: :province, prefix: true, allow_nil: true
  delegate :name, to: :district, prefix: true, allow_nil: true

  belongs_to :province
  belongs_to :district
  belongs_to :commune
  belongs_to :village
  belongs_to :user
  belongs_to :referral_source
  belongs_to :referral_source_category, class_name: 'ReferralSource'

  belongs_to :received_by,      class_name: 'User',      foreign_key: 'received_by_id'
  belongs_to :followed_up_by,   class_name: 'User',      foreign_key: 'followed_up_by_id'

  has_many :community_donors, dependent: :destroy
  has_many :donors, through: :community_donors
  has_many :case_worker_communities, dependent: :destroy
  has_many :case_workers, through: :case_worker_communities, validate: false

  has_many :community_quantitative_cases, dependent: :destroy
  has_many :quantitative_cases, through: :community_quantitative_cases

  has_many :custom_field_properties, as: :custom_formable, dependent: :destroy
  has_many :custom_fields, through: :custom_field_properties, as: :custom_formable
  has_many :community_members, dependent: :destroy

  accepts_nested_attributes_for :community_members, reject_if: :all_blank, allow_destroy: true

  has_paper_trail
end
