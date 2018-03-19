feature 'Case' do
  let!(:admin){ create(:user, roles: 'admin')}
  let!(:user){ create(:user)}
  let!(:client){ create(:client, :accepted, users: [user])}
  let!(:family){ create(:family)}
  let!(:accepted_client) { create(:client, :accepted, users: [user]) }
  let!(:ec_case){ create(:case, case_type: 'EC', client: accepted_client) }

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

    feature 'enable edit link' do
      before do
        login_as(admin)
      end
      scenario 'EC' do
        visit client_cases_path(client, case_type: 'EC')
        expect(page).to have_link(nil, href: edit_client_case_path(inactive_ec.client, inactive_ec))
      end
      scenario 'FC' do
        visit client_cases_path(client, case_type: 'FC')
        expect(page).to have_link(nil, href: edit_client_case_path(inactive_fc.client, inactive_fc))
      end
      scenario 'KC' do
        visit client_cases_path(client, case_type: 'KC')
        expect(page).to have_link(nil, href: edit_client_case_path(inactive_kc.client, inactive_kc))
      end
    end
  end

  feature 'Create' do
    scenario 'valid' do
      visit new_client_case_path(client, case_type: 'FC')
      fill_in 'Carer Name', with: 'Carer Name'
      fill_in 'Start Date', with: FFaker::Time.date
      click_button 'Save'
      expect(page).to have_content('Foster Care')
      expect(page).to have_content('Carer Name')
    end

    scenario 'case type' do
      visit new_client_case_path(client, case_type: 'FC')
      value = page.find(:css, '#case_case_type').value()
      expect(value).to have_content('FC')
    end

    scenario 'EC without family' do
      visit new_client_case_path(client, case_type: 'EC')
      fill_in 'Carer Names', with: 'Jonh'
      fill_in 'Start Date', with: '2017-04-01'
      click_button 'Save'
      expect(page).to have_content('Jonh')
      expect(page).to have_content('April 01, 2017')
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

      sleep 1
      expect(page).to have_content('Carer Name')
    end

    scenario 'invalid' do
      fill_in 'Start Date', with: ''
      click_button 'Save'

      sleep 1
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Exit', js: true do
    before do
      visit client_path(accepted_client)
    end

    scenario 'success' do
      page.find("button[data-target='#exit-from-case']").click
      within('#exit-from-case') do
        fill_in 'Exit Date', with: '2017-07-01'
        fill_in 'Exit Note', with: FFaker::Lorem.paragraph
      end
      page.find('input[type="submit"][value="Exit"]').click

      expect(page).to have_content('Accepted')
    end
  end
end
