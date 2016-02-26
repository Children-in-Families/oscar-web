describe 'Case' do
  let!(:user){ create(:user)}
  let!(:client){ create(:client,  state: 'accepted', user: user)}
  let!(:family){ create(:family)}
  let!(:carer_names){ FFaker::Name.name }
  let!(:accepted_client) { create(:client, state: 'accepted', user: user) }
  let!(:kc_case){ create(:case, case_type: 'KC', client: accepted_client) }

  before do
    login_as(user)
  end

  context 'Create' do
    before do
      visit new_client_case_path(client, case_type: 'FC')
    end
    scenario 'Valid' do
      fill_in 'Carer Names', with: carer_names
      select family.name, :from => "Family"
      click_button 'Create Case'
      expect(page).to have_content('Case has been successfully created')
      expect(page).to have_content('Foster Care')
      expect(page).to have_content(carer_names)
    end

    xscenario 'Invalid' do
      click_button 'Create Case'
      expect(page).to have_content('Unsuccessfully create case')
    end

    scenario 'Case type' do
      case_type = page.first('#case_case_type').text
      expect(case_type).to have_content('FC')
    end
  end

  context 'Exit' do
    before do
      visit client_path(accepted_client)
      fill_in 'Date', with: Date.strptime(FFaker::Time.date).strftime('%B %d, %Y')
      fill_in 'Note', with: FFaker::Lorem.paragraph
      first('input[type="submit"][value="Exit"]').click
    end
    scenario 'success' do
      expect(page).to have_content('Case has been successfully updated')
    end

    scenario 'has new case note link' do
      expect(page).to have_link('Add EC', href: new_client_case_path(accepted_client, case_type: 'EC'))
      expect(page).to have_link('Add FC', href: new_client_case_path(accepted_client, case_type: 'FC'))
      expect(page).to have_link('Add KC', href: new_client_case_path(accepted_client, case_type: 'KC'))
    end

    scenario 'has case type history link' do
      history_path = client_cases_path(accepted_client, case_type: kc_case.case_type)
      expect(page).to have_link("View #{kc_case.case_type} History", href: history_path)
    end
  end

end
