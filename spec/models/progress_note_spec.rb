# describe ProgressNote, 'associations' do
#   it { is_expected.to belong_to(:client) }
#   it { is_expected.to belong_to(:progress_note_type) }
#   it { is_expected.to belong_to(:location) }
#   it { is_expected.to belong_to(:material) }
#   it { is_expected.to belong_to(:user) }
#   it { is_expected.to have_many(:attachments).dependent(:destroy) }
#   it { is_expected.to have_and_belong_to_many(:interventions)}
#   it { is_expected.to have_and_belong_to_many(:assessment_domains)}
# end
#
# describe ProgressNote, 'validations' do
#   let!(:location){ create(:location, name: 'ផ្សេងៗ Other') }
#   it { is_expected.to validate_presence_of(:client_id)}
#   it { is_expected.to validate_presence_of(:user_id)}
#   it { is_expected.to validate_presence_of(:date)}
# end
#
# describe ProgressNote, 'scopes' do
#   let!(:location){ create(:location, name: 'ផ្សេងៗ Other') }
#   let!(:progress_note){ create(:progress_note, other_location: 'Home') }
#   context 'other_location_like' do
#     let!(:progress_notes){ ProgressNote.other_location_like(progress_note.other_location) }
#     it 'should include progress note with other location like' do
#       expect(progress_notes).to include(progress_note)
#     end
#   end
# end
#
# describe ProgressNote, 'callbacks' do
#   let!(:other_location){ create(:location, name: 'ផ្សេងៗ Other') }
#   let!(:location){ create(:location, name: FFaker::Address.city) }
#   let!(:progress_note){ create(:progress_note, location: location) }
#   let!(:other_progress_note){ create(:progress_note, location: other_location) }
#   context 'toggle_other_location' do
#     it 'choose other location should save value of other location field' do
#       expect(progress_note.other_location).to eq('')
#     end
#     it 'choose existing location should not save value of other location field' do
#       expect(other_progress_note.other_location).to eq(other_progress_note.other_location)
#     end
#   end
# end
#
# describe ProgressNote, 'methods' do
#   let!(:location){ create(:location, name: 'ផ្សេងៗ Other') }
#   let!(:other_location){ create(:location, name: FFaker::Address.city) }
#   let!(:progress_note){ create(:progress_note, location: location) }
#   let!(:other_progress_note){ create(:progress_note, location: other_location) }
#   context 'other_location?' do
#     it 'shoud be true' do
#       expect(progress_note.other_location?).to be_truthy
#     end
#     it 'shoud be false' do
#       expect(other_progress_note.other_location?).to be_falsey
#     end
#   end
# end
