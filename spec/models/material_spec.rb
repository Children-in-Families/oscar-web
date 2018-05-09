# describe Material, 'associations' do
#   it { is_expected.to have_many(:progress_notes).dependent(:restrict_with_error)}
# end
#
# describe Material, 'validations' do
#   it { is_expected.to validate_presence_of(:status) }
#   it { is_expected.to validate_uniqueness_of(:status).case_insensitive }
# end
#
# describe Material, 'methods' do
#   let!(:location){ create(:location, name: 'ផ្សេងៗ Other') }
#   let!(:material){ create(:material) }
#   let!(:used_material){ create(:material) }
#   let!(:progress_note){ create(:progress_note, material: used_material, location: location) }
# end
