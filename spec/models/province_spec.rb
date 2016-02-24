require 'rails_helper'

RSpec.describe Province, 'associations', type: :model do
  it { is_expected.to have_many(:villages) }
  it { is_expected.to have_many(:case_workers) }
end
