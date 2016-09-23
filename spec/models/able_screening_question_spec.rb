RSpec.describe AbleScreeningQuestion, type: :model do

  describe 'Validation' do
    it { is_expected.to validate_presence_of(:question) }
    it { is_expected.to validate_presence_of(:mode) }

    it { is_expected.to validate_inclusion_of(:mode).in_array(['yes_no', 'multiple', 'free_text']) }
  end

  describe 'Association' do
    it { is_expected.to belong_to(:stage) }
    it { is_expected.to have_many(:answers) }
    it { is_expected.to have_many(:clients).through(:answers) }
  end
end
