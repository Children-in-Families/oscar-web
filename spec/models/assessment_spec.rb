require 'rails_helper'

RSpec.describe Assessment, 'associations', type: :model do
  it { is_expected.to belong_to(:case_worker) }
  it { is_expected.to belong_to(:kinship_or_foster_care_case) }
end
