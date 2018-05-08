# describe Location, 'associations' do
#   it { is_expected.to have_many(:progress_notes).dependent(:restrict_with_error)}
# end
#
# describe Location, 'validations' do
#   it { is_expected.to validate_presence_of(:name) }
#   it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
# end
#
# describe Location, 'methods' do
#   let!(:location){ create(:location, name: 'ផ្សេងៗ Other') }
#   let!(:used_location){ create(:location) }
#   let!(:progress_note){ create(:progress_note, location: used_location) }
#
#   context 'is_other?' do
#     it{ expect(location.other_used).to eq(1) }
#     it{ expect(used_location.other_used).to eq(0) }
#   end
# end
