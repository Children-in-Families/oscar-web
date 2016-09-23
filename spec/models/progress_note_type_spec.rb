describe ProgressNoteType, 'associations' do
  it { is_expected.to have_many(:progress_notes).dependent(:restrict_with_error)}
end

describe ProgressNoteType, 'validations' do
  it { is_expected.to validate_presence_of(:note_type)}
  it { is_expected.to validate_uniqueness_of(:note_type)}
end

describe ProgressNoteType, 'methods' do
  let!(:location){ create(:location, name: 'ផ្សេងៗ Other') }
  let!(:progress_note_type){ create(:progress_note_type) }
  let!(:used_progress_note_type){ create(:progress_note_type) }
  let!(:progress_note){ create(:progress_note, progress_note_type: used_progress_note_type, location: location) }
  context 'has_no_any_progress_notes?' do
    it{ expect(progress_note_type.has_no_any_progress_notes?).to be_truthy }
    it{ expect(used_progress_note_type.has_no_any_progress_notes?).to be_falsey }
  end
end
