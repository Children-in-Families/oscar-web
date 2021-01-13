module FamilyScope
  extend ActiveSupport::Concern

  included do
    scope :address_like,               ->(value) { where('address iLIKE ?', "%#{value.squish}%") }
    scope :caregiver_information_like, ->(value) { where('caregiver_information iLIKE ?', "%#{value.squish}%") }
    scope :relevant_information_like,  ->(value) { where('relevant_information iLIKE ?', "%#{value.squish}%") }
    scope :case_history_like,          ->(value) { where('case_history iLIKE ?', "%#{value.squish}%") }
    scope :family_id_like,             ->(value) { where('code iLIKE ?', "%#{value.squish}%") }
    scope :street_like,                ->(value) { where('street iLIKE ?', "%#{value.squish}%") }
    scope :house_like,                 ->(value) { where('house iLIKE ?', "%#{value.squish}%") }
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
    scope :name_like,                  ->(value) { where('name iLIKE ?', "%#{value.squish}%") }
    scope :name_en_like,               ->(value) { where('name_en iLIKE ?', "%#{value.squish}%") }
    scope :referee_phone_number_like,  ->(value) { where('referee_phone_number iLIKE ?', "%#{value.squish}%") }
    scope :province_are,               ->        { joins(:province).pluck('provinces.name', 'provinces.id').uniq }
    scope :as_non_cases,               ->        { where.not(family_type: ['Short Term / Emergency Foster Care', 'Long Term Foster Care', 'Extended Family / Kinship Care']) }
    scope :by_status,                  ->(value) { where(status: value) }
    scope :by_family_type,             ->(value) { where(family_type: value) }
    scope :referral_source_is,         ->        { joins(:referral_source).where.not('referral_sources.name in (?)', ReferralSource::REFERRAL_SOURCES).pluck('referral_sources.name', 'referral_sources.id').uniq }
  end
end
