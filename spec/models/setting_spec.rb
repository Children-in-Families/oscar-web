describe Setting, 'validation' do
  context 'max assessment greater than 3 if assessment frequency is month' do
    subject { Setting.new(max_assessment: 4, assessment_frequency: 'month') }
    it { expect(subject.valid?).to be_truthy }
  end

  context 'max assessment cannot less than 3 if assessment frequency is month' do
    subject { Setting.new(max_assessment: 2, assessment_frequency: 'month') }
    it { expect(subject.valid?).to be_falsey }
  end

  context 'max assessment greater than 0 if assessment frequency is year' do
    subject { Setting.new(max_assessment: 1, assessment_frequency: 'year') }
    it { expect(subject.valid?).to be_truthy }
  end

  context 'max assessment cannot equal 0 if assessment frequency is year' do
    subject { Setting.new(max_assessment: 0, assessment_frequency: 'year') }
    it { expect(subject.valid?).to be_falsey }
  end

  context 'max case note greater than 0' do
    subject { Setting.new(max_case_note: 2) }
    it { expect(subject.valid?).to be_truthy }
  end

  context 'max case note cannot equal 0' do
    subject { Setting.new(max_case_note: 0) }
    it { expect(subject.valid?).to be_falsey }
  end

  context 'age greater than 0 and less than 100' do
    subject { Setting.new(age: 18) }
    it { expect(subject.valid?).to be_truthy }
  end

  context 'age equal 100' do
    subject { Setting.new(age: 100) }
    it { expect(subject.valid?).to be_truthy }
  end

  context 'age cannot equal 0' do
    subject { Setting.new(age: 0) }
    it { expect(subject.valid?).to be_falsey }
  end

  context 'age greater than 100' do
    subject { Setting.new(age: 110) }
    it { expect(subject.valid?).to be_falsey }
  end

  context 'max assessment and max case note should have value if frequency present' do
    subject { Setting.new(assessment_frequency: 'day', case_note_frequency: 'day') }
    it { expect(subject.valid?).to be_falsey }
  end

  context 'custom_assessment_name' do
    subject { Setting.new(enable_custom_assessment: true, custom_assessment: 'custom CSI tool') }
    it 'must not contain the term CSI' do
      expect(subject.valid?).to be_falsey
      expect(subject.errors[:custom_assessment]).to include('name is invalid')
    end
  end

  # context 'min assessment, max assessment and max case note greater than zero' do
  #   subject { Setting.new(min_assessment: 0, max_assessment: 0, max_case_note: 0) }
  #   it { expect(subject.valid?).to be_falsey }
  # end

  # context 'greater than min assessment' do
  #   subject { Setting.new(min_assessment: 2, max_assessment: 1) }
  #   it { expect(subject.valid?).to be_falsey }
  # end

  # context 'less than max assessment' do
  #   subject { Setting.new(min_assessment: 5, max_assessment: 2) }
  #   it { expect(subject.valid?).to be_falsey }
  # end

  # context 'min assessment, max assessment and max case note should have value if frequency present' do
  #   subject { Setting.new(assessment_frequency: 'day', case_note_frequency: 'day') }
  #   it { expect(subject.valid?).to be_falsey }
  # end
end
