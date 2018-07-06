# Client ask to hide #147254199

# describe GovernmentReport, 'associations' do
#   it { is_expected.to belong_to(:client) }
# end
#
# describe GovernmentReport, 'validations' do
#   it { is_expected.to validate_presence_of(:client)}
#   it { is_expected.to validate_presence_of(:code)}
#
#   context 'uniqueness of code' do
#     let!(:government_report) { create(:government_report, code: 'abc') }
#     it 'is valid' do
#       valid_report = build(:government_report, code: 'def')
#       expect(valid_report.save).to be true
#     end
#
#     it 'is invalid' do
#       invalid_report = build(:government_report, code: 'abc')
#       expect(invalid_report.save).to be false
#     end
#   end
# end
