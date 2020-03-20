module ClientConstants
  extend ActiveSupport::Concern

  REFEREE_RELATIONSHIPS = ['Self', 'Family Member', 'Friend', 'Helping Professional', 'Government / Local Authority', 'Other'].freeze
  RELATIONSHIP_TO_CALLER = ['Self', 'Child', 'Family Member', 'Friend', 'In same community', 'Client', 'Stranger', 'Other'].freeze
  ADDRESS_TYPES    = ['Home', 'Business', 'RCI', 'Dormitory', 'Other'].freeze
  PHONE_OWNERS    = ['Self', 'Family Member', 'Friend', 'Helping Professional', 'Government / Local Authority', 'Other'].freeze
  HOTLINE_FIELDS  = %w(nickname concern_is_outside concern_outside_address concern_province_id concern_district_id concern_commune_id concern_village_id concern_street concern_house concern_address concern_address_type concern_phone concern_phone_owner concern_email concern_email_owner concern_location concern_same_as_client location_description phone_counselling_summary)
  EXIT_REASONS    = ['Client is/moved outside NGO target area (within Cambodia)', 'Client is/moved outside NGO target area (International)', 'Client refused service', 'Client does not meet / no longer meets service criteria', 'Client died', 'Client does not require / no longer requires support', 'Agency lacks sufficient resources', 'Other']
  CLIENT_STATUSES = ['Accepted', 'Active', 'Exited', 'Referred'].freeze
  HEADER_COUNTS   = %w( date_of_call case_note_date case_note_type exit_date accepted_date date_of_assessments date_of_custom_assessments program_streams programexitdate enrollmentdate quantitative-type type_of_service).freeze
  BRC_ADDRESS     = %w(current_island current_street current_po_box current_city current_settlement current_resident_own_or_rent current_household_type island2 street2 po_box2 city2 settlement2 resident_own_or_rent2 household_type2).freeze

  GRADES = ['Kindergarten 1', 'Kindergarten 2', 'Kindergarten 3', 'Kindergarten 4', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', 'Year 1', 'Year 2', 'Year 3', 'Year 4', 'Year 5', 'Year 6', 'Year 7', 'Year 8'].freeze
  GENDER_OPTIONS  = ['female', 'male', 'other', 'unknown']
  CLIENT_LEVELS   = ['No', 'Level 1', 'Level 2']

  DIFFICULTIES = [
    'Difficulty hearing, even using hearing aid',
    'Difficulty remebering or concentrating',
    'Difficulty seeing, even if wearing glasses',
    'Difficulty walking or climbing steps',
    'Difficulty with (self-care such as) washing or dressing',
    'Using your usual language, do you have dificulty communicating, for example understanding or being understood'
  ].freeze

  HOUSEHOLD_MEMBERS = [
    'Children: 1',
    'Children: 2',
    'Children: 3',
    'Children: 4',
    'Children: 5',
    'Children: More than 5',
    'Females: 1',
    'Females: 2',
    'Females: 3',
    'Females: 4',
    'Females: 5',
    'Females: More than 5',
    'Males: 1',
    'Males: 2',
    'Males: 3',
    'Males: 4',
    'Males: 5',
    'Males: More than 5',
    'Missing: 1',
    'Missing: 2',
    'Missing: 3',
    'Missing: 4',
    'Missing: 5',
    'Missing: More than 5'
  ].freeze

  INTERVIEW_LOCATIONS = [
    'Abaco',
    'Grand Bahama',
    'New Providance',
    'Other'
  ].freeze

  HOSTING_NUMBER = [
    '1',
    '2',
    '3',
    '4',
    '5',
    'More than 5'
  ].freeze

  BIC_OTHERS = [
    'Consent + Contact via 3rd party mess',
    'Have received RFL/PSS support',
    'Hurricane related',
    'Pregnant woman in the household'
  ]
end
