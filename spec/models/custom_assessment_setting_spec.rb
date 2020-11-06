require 'rails_helper'

RSpec.describe CustomAssessmentSetting, type: :model do
  describe CustomAssessmentSetting, 'associations' do
    it { is_expected.to belong_to(:setting) }
    it { is_expected.to have_many(:domains).dependent(:destroy) }
    it { is_expected.to have_many(:case_notes).dependent(:restrict_with_error) }
  end

  describe CustomAssessmentSetting, 'validations' do
    before do
      allow_any_instance_of(CustomAssessmentSetting).to receive(:enable_custom_assessment).and_return(true)
    end
    it { should validate_numericality_of(:max_custom_assessment).only_integer }
    it { is_expected.to validate_presence_of(:custom_assessment_name) }
    it { is_expected.to validate_presence_of(:max_custom_assessment) }
    it { is_expected.to validate_presence_of(:custom_age) }

    context 'max assessment greater than 3 if assessment frequency is month' do
      subject { CustomAssessmentSetting.new(max_custom_assessment: 4, custom_assessment_frequency: 'month') }
      it { expect(subject.valid?).to be_truthy }
    end

    context 'max assessment cannot less than 3 if assessment frequency is month' do
      subject { CustomAssessmentSetting.new(max_custom_assessment: 2, custom_assessment_frequency: 'month') }
      it { expect(subject.valid?).to be_truthy }
    end

    context 'max assessment greater than 0 if assessment frequency is year' do
      subject { CustomAssessmentSetting.new(max_custom_assessment: 1, custom_assessment_frequency: 'year') }
      it { expect(subject.valid?).to be_truthy }
    end

    context 'max assessment cannot equal 0 if assessment frequency is year' do
      subject { CustomAssessmentSetting.new(max_custom_assessment: 0, custom_assessment_frequency: 'year') }
      it { expect(subject.valid?).to be_falsey }
    end

    context 'custom_age greater than 0 and less than 100' do
      subject { CustomAssessmentSetting.new(custom_age: 18) }
      it { expect(subject.valid?).to be_truthy }
    end

    context 'custom_age equal 100' do
      subject { CustomAssessmentSetting.new(custom_age: 100) }
      it { expect(subject.valid?).to be_truthy }
    end

    context 'custom_age cannot equal 0' do
      subject { CustomAssessmentSetting.new(custom_age: 0) }
      it { expect(subject.valid?).to be_falsey }
    end

    context 'custom_age greater than 100' do
      subject { CustomAssessmentSetting.new(custom_age: 110) }
      it { expect(subject.valid?).to be_falsey }
    end

    context 'custom max assessment and custom assessment name should have value if custom_assessment_frequency present' do
      subject { CustomAssessmentSetting.new(custom_assessment_frequency: 'day') }
      it { expect(subject.valid?).to be_falsey }
    end

  end
end
