RSpec.describe Stage, type: :model do

  describe 'Association' do
    it { is_expected.to have_many(:able_screening_questions) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:from_age) }
    it { is_expected.to validate_presence_of(:to_age) }
    it 'should validate uniqueness of to_age scoped to from_age' do
      FactoryGirl.create(:stage)
      should validate_uniqueness_of(:to_age).scoped_to(:from_age)
    end
    it 'should validate numericality of to_age to be greater than from_age' do
      stage = FactoryGirl.create(:stage)
      expect(stage.to_age).to be > stage.from_age
    end
  end

  describe 'Callbacks' do
    context 'check_question_mode' do
      let!(:stage)              { create(:stage) }
      let!(:question_group)     { create(:question_group) }
      let!(:free_text_question) { create(:able_screening_question, stage: stage, question_group: question_group, mode: AbleScreeningQuestion::MODES[1]) }

      it { expect(free_text_question.alert_manager).to be_falsey }
    end
  end

  describe 'Methods' do
    context 'from_age_as_date' do
      let!(:stage) { create(:stage, from_age: 1) }
      it { expect(stage.from_age_as_date).to eq('Sat, 31 Oct 2015'.to_date) }
    end
    context 'to_age_as_date' do
      let!(:stage) { create(:stage, to_age: 2) }
      it { expect(stage.to_age_as_date).to eq('Wed, 01 Oct 2014'.to_date) }
    end
  end
end