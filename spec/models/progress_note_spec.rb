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
  it { is_expected.to validate_presence_of(:date)}
#   FactoryGirl.create(:location, name: 'Other')
#   name           = 'Other'
#   other_location = Location.other(name).first
#   # other          = where('lower(name) like ?', name.downcase)
#   subject{ ProgressNote.new }

#   it { is_expected.to validate_presence_of(:date)}
#   it { is_expected.to validate_presence_of(:client_id)}
#   it { is_expected.to validate_presence_of(:progress_note_type_id)}
#   it { is_expected.to validate_presence_of(:location_id)}

#   context 'if other location' do
#     before { subject.location = other }
#     it { is_expected.to validate_presence_of(:other_location) }
#   end
end
