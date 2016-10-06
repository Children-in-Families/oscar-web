describe Location, 'associations' do
  it { is_expected.to have_many(:progress_notes).dependent(:restrict_with_error)}
end

describe Location, 'validations' do
  it { is_expected.to validate_presence_of(:name)}
  it { is_expected.to validate_uniqueness_of(:name)}
end

describe Location, 'methods' do
  let!(:location){ create(:location, name: 'ផ្សេងៗ Other') }
  let!(:used_location){ create(:location) }
  let!(:progress_note){ create(:progress_note, location: used_location) }
  context 'has_no_any_progress_notes?' do
    it{ expect(location.has_no_any_progress_notes?).to be_truthy }
    it{ expect(used_location.has_no_any_progress_notes?).to be_falsey }
  end

  context 'is_other?' do
    it{ expect(location.is_other?).to be_truthy }
    it{ expect(used_location.is_other?).to be_falsey }
  end
end
