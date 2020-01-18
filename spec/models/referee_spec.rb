require 'rails_helper'

RSpec.describe Referee, type: :model do
  describe Referee, 'associations' do
    it { is_expected.to belong_to(:province) }
    it { is_expected.to belong_to(:district) }
    it { is_expected.to belong_to(:commune) }
    it { is_expected.to belong_to(:village) }

    it { is_expected.to have_many(:clients) }
    it { is_expected.to have_many(:calls) }
  end
end
