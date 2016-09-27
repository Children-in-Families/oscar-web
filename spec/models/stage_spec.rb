RSpec.describe Stage, type: :model do

  describe 'Association' do
    it { is_expected.to have_many(:able_screening_questions) }
  end

end
