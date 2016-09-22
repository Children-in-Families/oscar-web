describe ProgressNote, 'associations' do
  it { is_expected.to belong_to(:client) }
  it { is_expected.to belong_to(:progress_note_type) }
  it { is_expected.to belong_to(:location) }
  it { is_expected.to belong_to(:material) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_and_belong_to_many(:interventions)}
  it { is_expected.to have_and_belong_to_many(:assessment_domains)}
end

describe ProgressNote, 'validations' do
  it { is_expected.to validate_presence_of(:client_id)}
  it { is_expected.to validate_presence_of(:user_id)}
  it { is_expected.to validate_presence_of(:date)}
end

describe ProgressNote, 'scopes' do
  let!(:progress_note){ create(:progress_note, other_location: 'Other Location') }
  context 'other_location_like' do
    let!(:progress_notes){ ProgressNote.other_location_like('OTHER location') }
    it 'should include progress note with other location like' do
      expect(progress_notes).to include(progress_note)
    end
  end
end
