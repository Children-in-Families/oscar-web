module ClientConstants
  extend ActiveSupport::Concern

  REFEREE_RELATIONSHIPS = ['Self', 'Family Member', 'Friend', 'Helping Professional', 'Government / Local Authority', 'Other'].freeze
  RELATIONSHIP_TO_CALLER = ['Self', 'Child', 'Family Member', 'Friend', 'In same community', 'Client', 'Stranger', 'Other'].freeze
  ADDRESS_TYPES    = ['Home', 'Business', 'RCI', 'Dormitory', 'Other'].freeze
  PHONE_OWNERS    = ['Self', 'Family Member', 'Friend', 'Helping Professional', 'Government / Local Authority', 'Other'].freeze
  HOTLINE_FIELDS  = %w(nickname concern_is_outside concern_outside_address concern_province_id concern_district_id concern_commune_id concern_village_id concern_street concern_house concern_address concern_address_type concern_phone concern_phone_owner concern_email concern_email_owner concern_location concern_same_as_client location_description phone_counselling_summary)
  EXIT_REASONS    = ['Client is/moved outside NGO target area (within Cambodia)', 'Client is/moved outside NGO target area (International)', 'Client refused service', 'Client does not meet / no longer meets service criteria', 'Client died', 'Client does not require / no longer requires support', 'Agency lacks sufficient resources', 'Other']
  CLIENT_STATUSES = ['Accepted', 'Active', 'Exited', 'Referred'].freeze
  HEADER_COUNTS   = %w( date_of_call case_note_date case_note_type exit_date accepted_date date_of_assessments date_of_custom_assessments program_streams programexitdate enrollmentdate quantitative-type type_of_service indirect_beneficiaries).freeze
  BRC_ADDRESS     = %w(current_island current_street current_po_box current_city current_settlement current_resident_own_or_rent current_household_type island2 street2 po_box2 city2 settlement2 resident_own_or_rent2 household_type2).freeze

  GENDER_OPTIONS  = ['female', 'male', 'lgbt', 'unknown', 'prefer_not_to_say', 'other']
  GRADES = ['Kindergarten 1', 'Kindergarten 2', 'Kindergarten 3', 'Kindergarten 4', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', 'Year 1', 'Year 2', 'Year 3', 'Year 4', 'Year 5', 'Year 6', 'Year 7', 'Year 8', 'Bachelors'].freeze
  CLIENT_LEVELS   = ['No', 'Level 1', 'Level 2']

  DUPLICATE_CHECKING_FIELDS = %i(given_name family_name local_family_name local_given_name date_of_birth current_province_id district_id commune_id village_id birth_province_id gender)

  LEGAL_DOC_FIELDS = %w(
    national_id_files
    birth_cert_files
    family_book_files
    passport_files
    travel_doc_files
    referral_doc_files
    local_consent_files
    police_interview_files
    other_legal_doc_files
    ngo_partner_files
    mosavy_files
    dosavy_files
    msdhs_files
    complain_files
    warrant_files
    verdict_files
    short_form_of_ocdm_files
    screening_interview_form_files
    short_form_of_mosavy_dosavy_files
    detail_form_of_mosavy_dosavy_files
    short_form_of_judicial_police_files
    detail_form_of_judicial_police_files
    letter_from_immigration_police_files
  )

  LEGAL_DOC_MAPPING = {
    national_id: :national_id_files,
    passport: :passport_files,
    birth_cert: :birth_cert_files,
    family_book: :family_book_files,
    travel_doc: :travel_doc_files,
    letter_from_immigration_police: :letter_from_immigration_police_files,
    ngo_partner: :ngo_partner_files,
    mosavy: :referral_doc_files,
    dosavy: :dosavy_files,
    msdhs: :msdhs_files,
    complain: :complain_files,
    local_consent: :local_consent_files,
    warrant: :warrant_files,
    verdict: :verdict_files,
    screening_interview_form: :screening_interview_form_files,
    short_form_of_ocdm: :short_form_of_ocdm_files,
    short_form_of_mosavy_dosavy: :short_form_of_mosavy_dosavy_files,
    detail_form_of_mosavy_dosavy: :detail_form_of_mosavy_dosavy_files,
    short_form_of_judicial_police: :short_form_of_judicial_police_files,
    police_interview: :police_interview_files,
    other_legal_doc: :other_legal_doc_files
  }.freeze

  BRC_RESIDENT_TYPES = [
    'Owner',
    "Rental",
    'Stable rental/lease, not at risk of eviction',
    'A short-term rental at risk of eviction',
    'A government, agency or religious shelter',
    "A friend or family member's home",
    'In a tent, destroyed building, or vehicle',
    "Back home",
    'Other'
  ].freeze

  BRC_BRANCHES = [
    "New Providence",
    "Grand Bahama",
    "Abaco Islands",
    "Acklins",
    "Andros",
    "Berry Islands",
    "Bimini",
    "Cat Island",
    "Crooked Island",
    "Eleuthera",
    "Exuma and Cays",
    "Harbour Island",
    "Inagua",
    "Long Island",
    "Mayaguana",
    "Ragged Island",
    "Rum Cay",
    "San Salvador",
    "Spanish Wells",
    "Other"
  ]

  BRC_PRESENTED_IDS = [
    "Bahamian Passport",
    "Driver's License",
    "Voter's Card",
    "National Insurance Card (NIB)",
    "Other"
  ].freeze

  BRC_PREFERED_LANGS = %w(
    English
    Creole
    French
  ).freeze

  MARITAL_STATUSES = %w(
    Married
    Single
    Divorced
  ).freeze

  ETHNICITY = [
    'Khmer',
    'Khmer Islam',
    'Vietnamese',
    'Other'
  ].freeze

  TRAFFICKING_TYPES = [
    'Labor trafficking',
    'Sex trafficking',
    'Others'
  ].freeze

  NATIONALITIES = %w(
    Cambodian
    Vietnamese
    Laotian
    Burmese
    Other
  ).freeze

  STACKHOLDER_CONTACTS_FIELDS = [
    :neighbor_name,
    :neighbor_phone,
    :dosavy_name,
    :dosavy_phone,
    :chief_commune_name,
    :chief_commune_phone,
    :chief_village_name,
    :chief_village_phone,
    :ccwc_name,
    :ccwc_phone,
    :legal_team_name,
    :legal_representative_name,
    :legal_team_phone,
    :other_agency_name,
    :other_representative_name,
    :other_agency_phone
  ].freeze
end
