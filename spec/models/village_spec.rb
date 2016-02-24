require 'rails_helper'

RSpec.describe Village, 'associations', type: :model do
  it { is_expected.to belong_to(:province) }
  it { is_expected.to have_many(:schools) }
  it { is_expected.to have_many(:partners) }
end
