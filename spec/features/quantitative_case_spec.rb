describe 'Quantitative Case' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:quantitative_type){ create(:quantitative_type) }
  let!(:quantitative_case){ create(:quantitative_case, quantitative_type: quantitative_type) }
  before do
    login_as(admin)
  end
  feature 'Version' do
    before do
      visit quantitative_case_version_path(quantitative_case)
    end
    scenario 'list all versions of this Quantitative Case' do
      expect(page).to have_content("Changelog of #{quantitative_case.value}")
    end
  end
end