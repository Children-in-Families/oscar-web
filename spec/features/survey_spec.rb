describe 'Survey' do
  let!(:user){ create(:user) }
  let!(:client){ create(:client, user: user) }
  let!(:survey){ create(:survey, client: client, user_id: client.user.id) }

  before do
    login_as(user)
  end

  feature 'List' do
    visit client_survey_path(client)
    expect(page).to have_content(survey.created_at.strftime('%B %d, %Y'))
  end

  feature 'Create' do
    before do
      visit new_client_survey_path(client)
    end

    scenario 'valid' do
      choose('.client_survey_listening_score_one')
      
      click_button 'Save'
      expect(page).to have_content('survey has successfully been created')
    end
    scenario 'invalid' do
      click_button 'Save'
      expect(page).to have_content("Please review the problems below")
    end
  end

  feature 'Update' do
    before do
      visit edit_client_survey_path(client, upcoming_survey)
    end
    scenario 'valid' do
      fill_in 'Enter survey details', with: FFaker::Name.name
      click_button 'Save'
      expect(page).to have_content('survey has successfully been updated')
    end
    scenario 'invalid' do
      fill_in 'Enter survey details', with: ''
      click_button 'Save'
      expect(page).to have_content("Please review the problems below")
    end
  end

  feature 'Delete' do
    before do
      visit client_surveys_path(client)
    end
    scenario 'successful' do
      find("a[href='#{client_survey_path(client, overdue_survey)}'][data-method='delete']").click
      expect(page).to have_content('survey has successfully been deleted')
    end
  end
end
