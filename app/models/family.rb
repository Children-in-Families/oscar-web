class Family < ActiveRecord::Base
  include EntityTypeCustomField
  TYPES = ['Birth Family (Both Parents)', 'Birth Family (Only Mother)',
    'Birth Family (Only Father)', 'Extended Family / Kinship Care',
    'Short Term / Emergency Foster Care', 'Long Term Foster Care',
    'Domestically Adopted', 'Child-Headed Household', 'No Family', 'Other']
  STATUSES = ['Active', 'Inactive']

  belongs_to :province, counter_cache: true

  has_many :cases, dependent: :restrict_with_error
  has_many :clients, through: :cases
  has_many :custom_field_properties, as: :custom_formable, dependent: :destroy
  has_many :custom_fields, through: :custom_field_properties, as: :custom_formable

  has_paper_trail

  validates :family_type, presence: true, inclusion: { in: TYPES }
  validates :code, uniqueness: { case_sensitive: false }, if: 'code.present?'
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :address_like,               ->(value) { where('address iLIKE ?', "%#{value}%") }
  scope :caregiver_information_like, ->(value) { where('caregiver_information iLIKE ?', "%#{value}%") }
  scope :case_history_like,          ->(value) { where('case_history iLIKE ?', "%#{value}%") }
  scope :family_id_like,             ->(value) { where('code iLIKE ?', "%#{value}%") }
  scope :emergency,                  ->        { where(family_type: 'Short Term / Emergency Foster Care') }
  scope :foster,                     ->        { where(family_type: 'Long Term Foster Care') }
  scope :kinship,                    ->        { where(family_type: 'Extended Family / Kinship Care') }
  scope :birth_family_both_parents,  ->        { where(family_type: 'Birth Family (Both Parents)') }
  scope :birth_family_only_father,   ->        { where(family_type: 'Birth Family (Only Father)') }
  scope :birth_family_only_mother,   ->        { where(family_type: 'Birth Family (Only Mother)') }
  scope :domestically_adopted,       ->        { where(family_type: 'Domestically Adopted') }
  scope :child_headed_household,     ->        { where(family_type: 'Child-Headed Household') }
  scope :no_family,                  ->        { where(family_type: 'No Family') }
  scope :other,                      ->        { where(family_type: 'Other') }
  scope :active,                     ->        { where(status: 'Active') }
  scope :inactive,                   ->        { where(status: 'Inactive') }
  scope :name_like,                  ->(value) { where('name iLIKE ?', "%#{value}%") }
  scope :province_are,               ->        { joins(:province).pluck('provinces.name', 'provinces.id').uniq }
  scope :as_non_cases,               ->        { where.not(family_type: ['Short Term / Emergency Foster Care', 'Long Term Foster Care', 'Extended Family / Kinship Care']) }
  scope :by_status,                  ->(value) { where(status: value) }
  scope :by_family_type,             ->(value) { where(family_type: value) }

  def member_count
    male_adult_count.to_i + female_adult_count.to_i + male_children_count.to_i + female_children_count.to_i
  end

  def emergency?
    family_type == 'Short Term / Emergency Foster Care'
  end

  def foster?
    family_type == 'Long Term Foster Care'
  end

  def kinship?
    family_type == 'Extended Family / Kinship Care'
  end

  def birth_family_both_parents?
    family_type == 'Birth Family (Both Parents)'
  end

  def inactive?
    status == 'Inactive'
  end

  def is_case?
    emergency? || foster? || kinship?
  end
end
