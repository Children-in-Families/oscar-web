class Partner < ActiveRecord::Base
  include EntityTypeCustomField
  belongs_to :province, counter_cache: true

  has_many :cases

  has_many :custom_field_properties, as: :custom_formable
  has_many :custom_fields, through: :custom_field_properties, as: :custom_formable

  has_paper_trail

  scope :name_like,                  ->(value) { where('name iLIKE ?', "%#{value}%") }
  scope :contact_person_name_like,   ->(value) { where('contact_person_name iLIKE ?', "%#{value}%") }
  scope :contact_person_email_like,  ->(value) { where('contact_person_email iLIKE ?', "%#{value}%") }
  scope :contact_person_mobile_like, ->(value) { where('contact_person_mobile iLIKE ?', "%#{value}%") }
  scope :affiliation_like,           ->(value) { where('affiliation iLIKE ?', "%#{value}%") }
  scope :engagement_like,            ->(value) { where('engagement iLIKE ?', "%#{value}%") }
  scope :background_like,            ->(value) { where('background iLIKE ?', "%#{value}%") }
  scope :address_like,               ->(value) { where('address iLIKE ?', "%#{value}%") }
  scope :organisation_type_are,      ->        { where.not(organisation_type: '').pluck(:organisation_type).uniq }
  scope :province_are,               ->        { joins(:province).pluck('provinces.name', 'provinces.id').uniq }
  scope :NGO,                        ->        { where(organisation_type: 'NGO') }
  scope :local_goverment,            ->        { where(organisation_type: 'Local Goverment') }
  scope :church,                     ->        { where(organisation_type: 'Church') }
end
