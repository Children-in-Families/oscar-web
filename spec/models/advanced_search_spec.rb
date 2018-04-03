describe AdvancedSearch, 'associations' do
  it { is_expected.to belong_to(:user) }
end

describe AdvancedSearch, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:user_id) }
end

describe AdvancedSearch, 'scopes' do
  let!(:user_1){ create(:user) }
  let!(:advanced_search_1){ create(:advanced_search, user: user_1) }
  let!(:advanced_search_2){ create(:advanced_search) }
  context 'non_of' do
    it 'returns all excluding those created by given user' do
      expect(AdvancedSearch.non_of(user_1)).not_to include(advanced_search_1)
      expect(AdvancedSearch.non_of(user_1)).to include(advanced_search_2)
    end
  end
end

describe AdvancedSearch, 'instance methods' do
  let!(:user_2){ create(:user, first_name: 'OSCaR', last_name: 'Hero') }
  let!(:advanced_search_3){ create(:advanced_search, user: user_2, queries: { 'name': 'OSCaR' }, field_visible: { 'all_' => 'all' }, custom_forms: 'a', program_streams: 'b', enrollment_check: 'c', tracking_check: 'd', exit_form_check: 'e', quantitative_check: 'f') }
  context 'owner' do
    it 'returns name of the owner' do
      expect(advanced_search_3.owner).to eq('OSCaR Hero')
    end
  end

  context 'search_params' do
    it 'returns a hash' do
      hash = { client_advanced_search: {
                  custom_form_selected: 'a',
                  program_selected: 'b',
                  enrollment_check: 'c',
                  tracking_check: 'd',
                  exit_form_check: 'e',
                  basic_rules: { 'name': 'OSCaR' }.to_json,
                  quantitative_check: 'f'
                }, 'all_' => 'all'
              }
      expect(advanced_search_3.search_params).to eq(hash)
    end
  end
end
