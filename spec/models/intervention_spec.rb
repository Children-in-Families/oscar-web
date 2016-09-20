describe Intervention, 'validations' do
  it { is_expected.to validate_presence_of(:action)}
  it { is_expected.to validate_uniqueness_of(:action)}
  it { is_expected.to have_and_belong_to_many(:progress_notes) }
end
