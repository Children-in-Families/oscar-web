describe Setting, 'validation' do
  context 'min assessment, max assessment and max case note greater than zero' do
    subject { Setting.new(min_assessment: 0, max_assessment: 0, max_case_note: 0) }
    it { expect(subject.valid?).to be_falsey }
  end

  context 'greater than min assessment' do
    subject { Setting.new(min_assessment: 2, max_assessment: 1) }
    it { expect(subject.valid?).to be_falsey }
  end

  context 'less than max assessment' do
    subject { Setting.new(min_assessment: 5, max_assessment: 2) }
    it { expect(subject.valid?).to be_falsey }
  end

  context 'min assessment, max assessment and max case note should have value if frequency present' do
    subject { Setting.new(assessment_frequency: 'day', case_note_frequency: 'day') }
    it { expect(subject.valid?).to be_falsey }
  end
end
