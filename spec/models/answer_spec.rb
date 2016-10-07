RSpec.describe Answer, type: :model do

  describe 'Association' do
    it { is_expected.to belong_to(:able_screening_question) }
    it { is_expected.to belong_to(:client) }
  end

  describe 'Scope' do
    let!(:client) { create(:client) }
    let!(:able_screening_question) { create(:able_screening_question, mode: 'yes_no') }
    let!(:general_answer) { create(:answer, question_type: 'general') }
    let!(:stage_answer) { create(:answer, question_type: 'stage') }
    context 'of general question' do
      it 'should include answers of general questions' do
        expect(Answer.of_general_question).to include(general_answer)
      end
      it 'should not include answers of stage questions' do
        expect(Answer.of_general_question).not_to include(stage_answer)
      end
    end
    context 'of stage question' do
      it 'should include answers of stage questions' do
        expect(Answer.of_stage_question).to include(stage_answer)
      end
      it 'should not include answers of general questions' do
        expect(Answer.of_stage_question).not_to include(general_answer)
      end
    end
  end
end
