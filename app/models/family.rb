class Family < ActiveRecord::Base
  include EntityTypeCustomField
  FAMILY_TYPE = %w(emergency kinship foster).freeze

  belongs_to :province, counter_cache: true

  has_many :cases
  has_many :clients, through: :cases
  has_many :custom_field_properties, as: :custom_formable
  has_many :custom_fields, through: :custom_field_properties, as: :custom_formable

  has_paper_trail

  validates :family_type, inclusion: { in: FAMILY_TYPE }
  validates :code, uniqueness: { case_sensitive: false }, if: 'code.present?'

  scope :address_like,               ->(value) { where('address iLIKE ?', "%#{value}%") }
  scope :caregiver_information_like, ->(value) { where('caregiver_information iLIKE ?', "%#{value}%") }
  scope :case_history_like,          ->(value) { where('case_history iLIKE ?', "%#{value}%") }
  scope :emergency,                  ->        { where(family_type: 'emergency') }
  scope :family_id_like,             ->(value) { where('code iLIKE ?', "%#{value}%") }
  scope :foster,                     ->        { where(family_type: 'foster')    }
  scope :kinship,                    ->        { where(family_type: 'kinship')   }
  scope :name_like,                  ->(value) { where('name iLIKE ?', "%#{value}%") }
  scope :province_are,               ->        { joins(:province).pluck('provinces.name', 'provinces.id').uniq }

  def member_count
    male_adult_count.to_i + female_adult_count.to_i + male_children_count.to_i + female_children_count.to_i
  end

  def self.by_family_type(type)
    if type == 'emergency'
      emergency
    elsif type == 'kinship'
      kinship
    elsif type == 'foster'
      foster
    end
  end
end
