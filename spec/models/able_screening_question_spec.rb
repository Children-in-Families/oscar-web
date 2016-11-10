RSpec.describe AbleScreeningQuestion, type: :model do

  describe 'Validation' do
    it { is_expected.to validate_presence_of(:question) }
    it { is_expected.to validate_uniqueness_of(:question).case_insensitive }
    it { is_expected.to validate_presence_of(:mode) }
    it { is_expected.to validate_inclusion_of(:mode).in_array(['yes_no', 'free_text']) }

    it 'validates group when it has stage' do
      stage = create(:stage)
      question_group = create(:question_group)
      able_screening_question = create(:able_screening_question, stage: stage, question_group: question_group)
      expect(able_screening_question).to validate_presence_of(:question_group)
    end

    it 'not validate group when it has stage' do
      able_screening_question = create(:able_screening_question)
      expect(able_screening_question).not_to validate_presence_of(:question_group)
    end
  end

  describe 'Association' do
    it { is_expected.to belong_to(:stage) }
    it { is_expected.to belong_to(:question_group) }
    it { is_expected.to have_many(:answers).dependent(:destroy) }
    it { is_expected.to have_many(:clients).through(:answers) }
    it { is_expected.to have_many(:attachments) }
  end

  describe 'Scope' do
    let!(:stage){ create(:stage, from_age: 1) }
    let!(:second_stage){ create(:stage, from_age: 2) }
    let!(:question_group){ create(:question_group) }
    let!(:first_question){ create(:able_screening_question,
      stage: stage, question_group: question_group) }
    context 'non_stage' do
      let!(:second_question){ create(:able_screening_question) }
      it 'returns non stage questions' do
        expect(AbleScreeningQuestion.non_stage).to include(second_question)
      end
      it 'does not return stage questions' do
        expect(AbleScreeningQuestion.non_stage).not_to include(first_question)
      end
    end
    context 'with_stage' do
      let!(:third_question){ create(:able_screening_question, stage: second_stage, question_group: question_group) }
      it 'return stage question order by from_age' do
        expect(AbleScreeningQuestion.with_stage).to eq([first_question, third_question])
      end
    end
  end

  describe 'Callback' do
    let!(:question) { create(:able_screening_question, mode: 'free_text') }
    context 'check mode' do
      it 'does not alert manager if free text' do
        expect(question.alert_manager).to be_falsey
      end
    end
  end

  describe 'Method' do
    let!(:stage){ create(:stage) }
    let!(:question_group){ create(:question_group) }
    let!(:client){ create(:client) }
    let!(:other_client){ create(:client) }

    let!(:first_question){ create(:able_screening_question, mode: 'yes_no', alert_manager: true) }
    let!(:second_question){ create(:able_screening_question, stage: stage, question_group: question_group, mode: 'free_text')}

    let!(:answer){ create(:answer, client: client, able_screening_question: first_question) }
    let!(:other_answer){ create(:answer, client: other_client, able_screening_question: second_question) }

    let!(:attachment){ create(:attachment, able_screening_question: first_question, image: 'myimg.jpg') }
    let!(:second_attachment){ create(:attachment, able_screening_question: first_question) }

    context 'has_image?' do
      it 'returns true' do
        expect(first_question.has_image?).to be_truthy
      end
      it 'returns false' do
        expect(second_question.has_image?).to be_falsey
      end
    end
    context 'first_image' do
      it 'returns first image' do
        expect(first_question.first_image.url).to eq(attachment.image.url)
      end
      it 'returns nil' do
        expect(second_question.first_image).to be nil
      end
    end
    context 'has_stage?' do
      it 'returns true' do
        expect(second_question.has_stage?).to be_truthy
      end
      it 'returns false' do
        expect(first_question.has_stage?).to be_falsey
      end
    end
    context 'free_text?' do
      it 'returns true' do
        expect(second_question.free_text?).to be_truthy
      end
    end
    context 'yes_no?' do
      it 'returns true' do
        expect(first_question.yes_no?).to be_truthy
      end
    end
    context 'has_alert_manager? of given client' do
      it 'returns true' do
        expect(AbleScreeningQuestion.has_alert_manager?(client)).to be_truthy
      end
      it 'returns false' do
        expect(AbleScreeningQuestion.has_alert_manager?(other_client)).to be_falsey
      end
    end
  end
end
