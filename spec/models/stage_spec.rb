RSpec.describe Stage, type: :model do

  describe 'Validation' do
    it { is_expected.to validate_presence_of(:from_age) }
    it { is_expected.to validate_presence_of(:to_age) }
  end

  describe 'Association' do
    it { is_expected.to have_many(:able_screening_questions) }
  end

end
