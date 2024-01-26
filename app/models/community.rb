class Community < ActiveRecord::Base
  extend Enumerize

  acts_as_paranoid

  mount_uploaders :documents, FileUploader

  delegate :name, to: :province, prefix: true, allow_nil: true
  delegate :name, to: :city, prefix: true, allow_nil: true
  delegate :name, to: :district, prefix: true, allow_nil: true
  delegate :name, to: :subdistrict, prefix: true, allow_nil: true
  delegate :name, to: :village, prefix: true, allow_nil: true
  delegate :name, to: :commune, prefix: true, allow_nil: true

  EN_RELATIONS = ['Father', 'Mother', 'Brother', 'Sister', 'Uncle', 'Aunt', 'Grandfather', 'Grandmother', 'Relative', 'Neighbor', 'Friend']
  KM_RELATIONS = ['ឪពុក', 'ម្ដាយ', 'បងប្រុស', 'បងស្រី', 'ពូ', 'មីង', 'អ៊ុំ', 'ជីដូន', 'ជីតា', 'សាច់ញាតិ', 'អ្នកជិតខាង', 'មិត្តភ័ក្ត']
  MY_RELATIONS = ['ဖခင်', 'မိခင်', 'အစ်ကို', 'အစ်မ', 'ဘကြီး', 'အဒေါ်', 'အဘိုး', 'အဖွါး', 'ဆွေမျိုး', 'အိမ်နီးချင်း', 'မိတျဆှေ']
  STATUSES = ['accepted', 'rejected', 'active']

  enumerize :gender, in: ['female', 'male', 'lgbt', 'unknown', 'prefer_not_to_say', 'other'], scope: :shallow, predicates: { prefix: true }
  enumerize :status, in: ['accepted', 'rejected', 'active'], scope: :shallow, predicates: { prefix: true }

  belongs_to :province
  belongs_to :city
  belongs_to :district
  belongs_to :subdistrict
  belongs_to :commune
  belongs_to :village
  belongs_to :user
  belongs_to :referral_source
  belongs_to :referral_source_category, class_name: 'ReferralSource'

  belongs_to :received_by, class_name: 'User'

  has_many :community_donors, dependent: :destroy
  has_many :donors, through: :community_donors

  has_many :case_worker_communities, dependent: :destroy
  has_many :case_workers, through: :case_worker_communities, validate: false

  has_many :community_quantitative_free_text_cases
  has_many :community_quantitative_cases, dependent: :destroy
  has_many :quantitative_cases, through: :community_quantitative_cases
  has_many :viewable_quantitative_cases, -> { joins(:quantitative_type).where('quantitative_types.visible_on LIKE ?', '%community%') }, through: :community_quantitative_cases, source: :quantitative_case

  has_many :custom_field_properties, as: :custom_formable, dependent: :destroy
  has_many :custom_fields, through: :custom_field_properties, as: :custom_formable
  has_many :community_members, dependent: :destroy
  has_many :families, through: :community_members
  has_many :enrollments, as: :programmable, dependent: :destroy
  has_many :program_streams, through: :enrollments, as: :programmable

  accepts_nested_attributes_for :community_quantitative_free_text_cases
  accepts_nested_attributes_for :community_members, reject_if: :all_blank, allow_destroy: true

  validates :received_by_id, :initial_referral_date, :case_worker_ids, presence: true

  has_paper_trail

  scope :referral_source_is, -> { joins(:referral_source).where.not('referral_sources.name in (?)', ReferralSource::REFERRAL_SOURCES).pluck('referral_sources.name', 'referral_sources.id').uniq }
  scope :by_status, -> (value) { where(status: value) }

  def display_name
    [name, name_en].select(&:present?).join(' - ').presence || "Community ##{id}"
  end

  def direct_beneficiaries
    self.community_members.count
  end

  def indirect_beneficiaries
    count = 0
    self.community_members.where.not(family_id: nil) do |member|
      count += member.where(family_id: member.family_id).member_count - 1 if member.where(family_id: member.family_id).member_count != 0
    end
    count
  end
end
