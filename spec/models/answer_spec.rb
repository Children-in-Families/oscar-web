RSpec.describe Answer, type: :model do

  describe 'Association' do
    it { is_expected.to belong_to(:able_screening_question) }
    it { is_expected.to belong_to(:client) }
  end
end
