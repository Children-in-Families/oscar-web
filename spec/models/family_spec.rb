require 'rails_helper'

RSpec.describe Family, 'associations', type: :model do
  it { is_expected.to have_many(:kinship_or_foster_care_cases) }
end
