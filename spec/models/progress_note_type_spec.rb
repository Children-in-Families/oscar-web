describe ProgressNoteType, 'associations' do
  it { is_expected.to have_many(:progress_notes).dependent(:restrict_with_error)}
end

describe ProgressNoteType, 'validations' do
  it { is_expected.to validate_presence_of(:note_type)}
  it { is_expected.to validate_uniqueness_of(:note_type)}
end
