describe Setting, 'validation' do
  let!(:setting){ create(:setting) }

  it { is_expected.to validate_numericality_of(:min_assessment).only_integer }
  it { is_expected.to validate_numericality_of(:max_assessment).only_integer }

  it 'should be greater than 0' do
    setting.min_assessment = 1
    setting.max_assessment = 1
    setting.valid?.should be_truthy
  end

  it 'should not be less than 1' do
    subject.min_assessment = 0
    subject.max_assessment = 0
    subject.valid?.should be_falsey
  end

end
