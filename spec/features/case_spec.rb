describe 'Case' do
  let!(:user){ create(:user)}
  let!(:client){ create(:client,  state: 'accepted', user: user)}
  let!(:family){ create(:family)}
  let!(:accepted_client) { create(:client, state: 'accepted', user: user) }
  let!(:kc_case){ create(:case, case_type: 'KC', client: accepted_client) }

  before do
    login_as(user)
  end

  feature 'History List' do
    let!(:active_ec){ create(:case, carer_names: 'EC Carer Name', case_type: 'EC', client: client) }
    let!(:active_fc){ create(:case, carer_names: 'FC Carer Name', case_type: 'FC', client: client) }
    let!(:active_kc){ create(:case, carer_names: 'KC Carer Name', case_type: 'KC', client: client) }
    let!(:inactive_ec){ create(:case, :inactive, carer_names: 'EC Inactive Carer Name', case_type: 'EC', client: client) }
    let!(:inactive_fc){ create(:case, :inactive, carer_names: 'FC Inactive Carer Name', case_type: 'FC', client: client) }
    let!(:inactive_kc){ create(:case, :inactive, carer_names: 'KC Inactive Carer Name', case_type: 'KC', client: client) }

    scenario 'EC' do
      visit client_cases_path(client, case_type: 'EC')

      expect(page).to have_content(inactive_ec.carer_names)

      expect(page).not_to have_content(active_ec.carer_names)
      expect(page).not_to have_content(active_fc.carer_names)
      expect(page).not_to have_content(active_kc.carer_names)
      expect(page).not_to have_content(inactive_fc.carer_names)
      expect(page).not_to have_content(inactive_kc.carer_names)
    end

    scenario 'FC' do
      visit client_cases_path(client, case_type: 'FC')

      expect(page).to have_content(inactive_fc.carer_names)

      expect(page).not_to have_content(active_ec.carer_names)
      expect(page).not_to have_content(active_fc.carer_names)
      expect(page).not_to have_content(active_kc.carer_names)
      expect(page).not_to have_content(inactive_ec.carer_names)
      expect(page).not_to have_content(inactive_kc.carer_names)
    end

    scenario 'KC' do
      visit client_cases_path(client, case_type: 'KC')

      expect(page).to have_content(inactive_kc.carer_names)

      expect(page).not_to have_content(active_ec.carer_names)
      expect(page).not_to have_content(active_fc.carer_names)
      expect(page).not_to have_content(active_kc.carer_names)
      expect(page).not_to have_content(inactive_ec.carer_names)
      expect(page).not_to have_content(inactive_fc.carer_names)
    end
  end

  feature 'Create' do
    scenario 'valid' do
      visit new_client_case_path(client, case_type: 'FC')
      fill_in 'Carer Name', with: 'Carer Name'
      fill_in 'Start Date', with: FFaker::Time.date
      select family.name, from: 'Family'
      click_button 'Save'
      expect(page).to have_content('Case has been successfully created')
      expect(page).to have_content('Foster Care')
      expect(page).to have_content('Carer Name')
    end

    xscenario 'invalid' do
      visit new_client_case_path(client, case_type: 'KC')
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end

    scenario 'case type' do
      visit new_client_case_path(client, case_type: 'FC')
      case_type = page.first('#case_case_type').text
      expect(case_type).to have_content('FC')
    end

    scenario 'EC without family' do
      visit new_client_case_path(client, case_type: 'EC')
      fill_in 'Carer Names', with: FFaker::Name.name
      fill_in 'Start Date', with: FFaker::Time.date
      click_button 'Save'
      expect(page).to have_content('Case has been successfully created')
    end
  end

  feature 'Update' do
    let!(:active_case){ create(:case, case_type: 'EC', client: client) }

    before do
      visit edit_client_case_path(client, active_case)
    end

    scenario 'valid' do
      fill_in 'Carer Names', with: 'Carer Name'
      click_button 'Save'
      expect(page).to have_content('Case has been successfully updated')
    end

    xscenario 'invalid'
  end

  feature 'Exit' do
    before do
      visit client_path(accepted_client)
      fill_in
    end

    def fill_in
      modal = find(:css, '#exitFromCase')
      modal.find('.exit_date').set(Date.strptime(FFaker::Time.date).strftime('%B %d, %Y'))
      modal.find('.exit_note').set(FFaker::Lorem.paragraph)
      modal.find('input[type="submit"][value="Exit"]').click
    end

    scenario 'success' do
      expect(page).to have_content('Case has been successfully updated')
    end

    scenario 'new case note link' do
      expect(page).to have_link('Add to EC', href: new_client_case_path(accepted_client, case_type: 'EC'))
      expect(page).to have_link('Add to FC', href: new_client_case_path(accepted_client, case_type: 'FC'))
      expect(page).to have_link('Add to KC', href: new_client_case_path(accepted_client, case_type: 'KC'))
    end

    scenario 'case type history link' do
      expect(page).to have_link("#{kc_case.case_type} History", href: client_cases_path(accepted_client, case_type: kc_case.case_type))
    end
  end
end
