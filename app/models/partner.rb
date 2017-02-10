class Partner < ActiveRecord::Base
  belongs_to :province, counter_cache: true

  has_many :cases

  has_many :partner_custom_fields
  has_many :custom_fields, through: :partner_custom_fields

  has_paper_trail

  scope :name_like,                  -> (value) { where('LOWER(partners.name) LIKE ?', "%#{value.downcase}%") }

  scope :contact_person_name_like,   -> (value) { where('LOWER(partners.contact_person_name) LIKE ?', "%#{value.downcase}%") }

  scope :contact_person_email_like,  -> (value) { where('LOWER(partners.contact_person_email) LIKE ?', "%#{value.downcase}%") }

  scope :contact_person_mobile_like, -> (value) { where('LOWER(partners.contact_person_mobile) LIKE ?', "%#{value.downcase}%") }

  scope :affiliation_like,           -> (value) { where('LOWER(partners.affiliation) LIKE ?', "%#{value.downcase}%") }

  scope :engagement_like,            -> (value) { where('LOWER(partners.engagement) LIKE ?', "%#{value.downcase}%") }

  scope :background_like,            -> (value) { where('LOWER(partners.background) LIKE ?', "%#{value.downcase}%") }

  scope :address_like,               -> (value) { where('LOWER(partners.address) LIKE ?', "%#{value.downcase}%") }

  scope :organisation_type_are,      ->         { where.not(organisation_type: '').pluck(:organisation_type).uniq }

  scope :province_are,               ->         { joins(:province).pluck('provinces.name', 'provinces.id').uniq }

  scope :NGO,                        ->         { where(organisation_type: 'NGO') }
  scope :local_goverment,            ->         { where(organisation_type: 'Local Goverment') }
  scope :church,                     ->         { where(organisation_type: 'Church') }

end
