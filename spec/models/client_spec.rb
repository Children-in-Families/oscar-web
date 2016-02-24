require 'rails_helper'

RSpec.describe Client, 'associations', type: :model do
  it { is_expected.to have_one(:emergency_care_case) }
  it { is_expected.to have_one(:kinship_or_foster_care_case) }

  it { is_expected.to belong_to(:school) }
  it { is_expected.to belong_to(:referral_recieved_by) }
  it { is_expected.to belong_to(:birth_village) }
  it { is_expected.to belong_to(:current_village) }
end
