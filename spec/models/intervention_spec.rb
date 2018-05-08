# describe Intervention, 'validations' do
#   it { is_expected.to validate_presence_of(:action) }
#   it { is_expected.to validate_uniqueness_of(:action).case_insensitive }
#   it { is_expected.to have_and_belong_to_many(:progress_notes) }
# end
#
# describe Intervention, 'methods' do
#   let!(:location){ create(:location, name: 'ផ្សេងៗ Other') }
#   let!(:intervention){ create(:intervention) }
#   let!(:used_intervention){ create(:intervention) }
#   let!(:progress_note){ create(:progress_note, intervention_ids: used_intervention.id, location: location) }
# end
#
# describe Intervention, 'scopes' do
#   let!(:intervention){ create(:intervention, action: 'Healthcare') }
#   let!(:other_intervention){ create(:intervention, action: 'Take medicine') }
#   context 'action like' do
#     it 'should include intervention with action like' do
#       expect(Intervention.action_like([intervention.action])).to include(intervention)
#     end
#     it 'should not include intervention with other action' do
#       expect(Intervention.action_like([intervention.action])).not_to include(other_intervention)
#     end
#   end
# end
