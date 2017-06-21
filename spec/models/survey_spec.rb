# Client ask to hide #147254199

# describe Survey, 'associations' do
#   it { is_expected.to belong_to(:client) }
# end
#
# describe Survey, 'validations' do
#   it { is_expected.to validate_presence_of(:listening_score) }
#   it { is_expected.to validate_presence_of(:problem_solving_score) }
#   it { is_expected.to validate_presence_of(:getting_in_touch_score) }
#   it { is_expected.to validate_presence_of(:trust_score) }
#   it { is_expected.to validate_presence_of(:difficulty_help_score) }
#   it { is_expected.to validate_presence_of(:support_score) }
#   it { is_expected.to validate_presence_of(:family_need_score) }
#   it { is_expected.to validate_presence_of(:care_score) }
# end
#
# describe Survey, 'callbacks' do
#   context 'set user id' do
#     let!(:user)   { create(:user) }
#     let!(:client) { create(:client, user: user) }
#
#     let!(:survey) { create(:survey, client: client,
#                                     listening_score: 4,
#                                     problem_solving_score: 4,
#                                     getting_in_touch_score: 4,
#                                     trust_score: 4,
#                                     difficulty_help_score: 4,
#                                     support_score: 4,
#                                     family_need_score: 4,
#                                     care_score: 4
#                                     ) }
#
#     before do
#       survey.user_id = client.user_id
#       survey.reload
#     end
#
#     it 'should set user id' do
#       expect(survey.user_id).to eq(user.id)
#     end
#   end
# end
