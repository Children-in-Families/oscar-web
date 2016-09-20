describe ProgressNoteType, 'validations' do
  it { is_expected.to validate_presence_of(:note_type)}
  it { is_expected.to validate_uniqueness_of(:note_type)}
end
