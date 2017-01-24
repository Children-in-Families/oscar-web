class Family < ActiveRecord::Base

  FAMILY_TYPE = ['emergency', 'kinship', 'foster'].freeze

  belongs_to :province, counter_cache: true
  has_many :cases
  has_many :clients, through: :cases

  validates :family_type, inclusion: { in: FAMILY_TYPE }

  has_paper_trail

  scope :name_like,                  -> (value) { where('LOWER(families.name) LIKE ?', "%#{value.downcase}%") }

  scope :caregiver_information_like, -> (value) { where('LOWER(families.caregiver_information) LIKE ?', "%#{value.downcase}%") }

  scope :address_like,               -> (value) { where('LOWER(families.address) LIKE ?', "%#{value.downcase}%") }

  scope :kinship,                    -> { where(family_type: 'kinship')   }
  scope :foster,                     -> { where(family_type: 'foster')    }
  scope :emergency,                  -> { where(family_type: 'emergency') }

  scope :province_are,               -> { joins(:province).pluck('provinces.name', 'provinces.id').uniq }

  def member_count
    male_adult_count.to_i + female_adult_count.to_i + male_children_count.to_i + female_children_count.to_i
  end

  def self.by_family_type(type)
    if type == 'emergency'
      self.emergency 
    elsif type =='kinship'
      self.kinship
    elsif type == 'foster'
      self.foster
    end
  end
end
