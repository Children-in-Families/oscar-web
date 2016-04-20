describe "Assessment" do
  let!(:user) { create(:user) }
  let!(:client) { create(:client, state: 'accepted', user: user) }
  let!(:fc_case) { create(:case, case_type: 'FC', client: client) }
  let!(:domain) { create(:domain, name: '1A') }

  before do
    login_as(user)
  end

  feature 'Create' do
    before do
      visit new_client_assessment_path(client)
    end

    scenario 'valid', js: true do
      choose('4')
      fill_in 'Reason', with: FFaker::Lorem.paragraph
      click_link 'Done'

      expect(page).to have_content('Assessment has been successfully created')
      expect(page).to have_content(domain.name)
      expect(page.find('.domain-score')).to have_content('4')
    end
  end

  feature 'List' do
    let!(:assessment){ create(:assessment, client: client) }
    let!(:assessment_domain){ create(:assessment_domain, assessment: assessment, domain: domain) }
    let!(:other_client){ create(:client, state: 'accepted', user: user) }
    let!(:last_assessment){ create(:assessment, created_at: Time.now - 7.month, client: other_client) }
    let!(:last_assessment_domain){ create(:assessment_domain, assessment: last_assessment, domain: domain) }

    before do
      visit client_assessments_path(client)
    end

    scenario 'view report' do
      expect(page).to have_link('View Report', href: client_assessment_path(client, assessment))
    end

    scenario 'no new assessment' do
      expect(page).not_to have_link('Begin now', href: new_client_assessment_path(client))
    end

    scenario 'new assessment' do
      visit client_assessments_path(other_client)
      expect(page).to have_link('Begin now', href: new_client_assessment_path(other_client))
    end

  end
end
