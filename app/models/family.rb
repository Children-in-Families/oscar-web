class Family < ActiveRecord::Base

  belongs_to :province, counter_cache: true
  has_many :cases
  has_many :clients, through: :cases

  has_paper_trail

  serialize :properties, JSON

  scope :name_like,                  -> (value) { where('LOWER(families.name) LIKE ?', "%#{value.downcase}%") }

  scope :caregiver_information_like, -> (value) { where('LOWER(families.caregiver_information) LIKE ?', "%#{value.downcase}%") }

  scope :address_like,               -> (value) { where('LOWER(families.address) LIKE ?', "%#{value.downcase}%") }

  scope :kinship,                    -> { where(family_type: 'kinship') }

  scope :foster,                     -> { where(family_type: 'foster') }

  scope :province_are,               -> { joins(:province).pluck('provinces.name', 'provinces.id').uniq }

  def member_count
    male_adult_count.to_i + female_adult_count.to_i + male_children_count.to_i + female_children_count.to_i
  end

  validate :present_of_custom_field

  def present_of_custom_field
    CustomField.find_by(entity_name: self.class.name).field_objs.each do |field|
      if field['required'] == true && JSON.parse(self.properties)[field['name']].blank?
        errors.add(field['name'], "can't be blank")
      end
    end
  end

  def properties_objs
    JSON.parse(properties) if properties.present?
  end

end
