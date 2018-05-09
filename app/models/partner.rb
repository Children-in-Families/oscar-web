class Partner < ActiveRecord::Base
  include EntityTypeCustomField
  belongs_to :province, counter_cache: true
  belongs_to :organization_type

  has_many :cases
  has_many :custom_field_properties, as: :custom_formable, dependent: :destroy
  has_many :custom_fields, through: :custom_field_properties, as: :custom_formable

  delegate :name, to: :organization_type, prefix: true, allow_nil: true

  has_paper_trail

  scope :name_like,                  ->(value) { where('name iLIKE ?', "%#{value}%") }
  scope :contact_person_name_like,   ->(value) { where('contact_person_name iLIKE ?', "%#{value}%") }
  scope :contact_person_email_like,  ->(value) { where('contact_person_email iLIKE ?', "%#{value}%") }
  scope :contact_person_mobile_like, ->(value) { where('contact_person_mobile iLIKE ?', "%#{value}%") }
  scope :affiliation_like,           ->(value) { where('affiliation iLIKE ?', "%#{value}%") }
  scope :engagement_like,            ->(value) { where('engagement iLIKE ?', "%#{value}%") }
  scope :background_like,            ->(value) { where('background iLIKE ?', "%#{value}%") }
  scope :address_like,               ->(value) { where('address iLIKE ?', "%#{value}%") }
  scope :organization_type_are,      ->        { joins(:organization_type).order('lower(organization_types.name)').pluck('organization_types.name', 'organization_types.id').uniq }
  scope :province_are,               ->        { joins(:province).pluck('provinces.name', 'provinces.id').uniq }
  scope :NGO,                        ->        { joins(:organization_type).where(organization_types: { name: 'NGO' }) }
  scope :local_goverment,            ->        { joins(:organization_type).where(organization_types: { name: 'Local Goverment' }) }
  scope :church,                     ->        { joins(:organization_type).where(organization_types: { name: 'Church' }) }
end
