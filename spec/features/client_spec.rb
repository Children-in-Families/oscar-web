describe 'Client' do
  let!(:user){ create(:user) }
  before do
    login_as(user)
  end

  context 'Index' do
    let!(:client){create(:client, user: user)}
    let!(:other_client){create(:client)}
    before do
      visit clients_path
    end

    scenario 'has new link' do
      expect(page).to have_link('Add New Client', href: new_client_path)
    end

    scenario 'has name' do
      expect(page).to have_content(client.name)
    end

    scenario 'has edit link' do
      expect(page).to have_link(nil, href: edit_client_path(client))
    end

    scenario 'has delete link' do
      expect(page).to have_css("a[href='#{client_path(client)}'][data-method='delete']")
    end

    scenario 'no other name' do
      expect(page).not_to have_content(other_client.name)
    end
  end

  context 'Show' do
    let!(:client){ create(:client, user: user) }
    before do
      visit client_path(client)
    end
    scenario 'has information' do
      expect(page).to have_content(client.name)
      expect(page).to have_content(client.gender)
      expect(page).to have_content(client.date_of_birth.strftime('%B %d, %Y'))
    end

    scenario 'has tasks link' do
      expect(page).to have_link('View Tasks', href: client_tasks_path(client))
    end

    scenario 'has assesstments link' do
      expect(page).to have_link('View Assessments', href: client_assessments_path(client))
    end

    scenario 'has case notes link' do
      expect(page).to have_link('View Case Notes', href: client_case_notes_path(client))
    end

    scenario 'has edit link' do
      expect(page).to have_link(nil, href: edit_client_path(client))
    end

    scenario 'has delete link' do
      expect(page).to have_css("a[href='#{client_path(client)}'][data-method='delete']")
    end
  end

  context 'New' do
    before do
      visit new_client_path
    end
    scenario 'valid' do
      fill_in 'First name', with: FFaker::Name.first_name
      fill_in 'Last name', with: FFaker::Name.last_name
      click_button 'Create Client'
      expect(page).to have_content('Client has been successfully created')
    end

    xscenario 'invalid' do
      click_button 'Create Client'
      expect(page).to have_content('Unsuccessfully create client')
    end
  end

  context 'Update' do
    let!(:client){ create(:client, user: user) }
    before do
      visit edit_client_path(client)
    end
    scenario 'valid' do
      fill_in 'First name', with: FFaker::Name.first_name
      fill_in 'Last name', with: FFaker::Name.last_name
      click_button 'Update Client'
      expect(page).to have_content('Client has been successfully updated')
    end

    xscenario 'invalid' do
      fill_in 'First name', with: ''
      fill_in 'Last name', with: ''
      click_button 'Update Client'
      expect(page).to have_content('Unsuccessfully update client')
    end
  end

  context 'Delete' do
    let!(:client){ create(:client, user: user) }
    before do
      visit clients_path
    end
    scenario 'successfully' do
      first("a[data-method='delete'][href='#{client_path(client)}']").click
      expect(page).to have_content('Client has been successfully deleted')
    end
  end

  context 'Accept' do
    let!(:client){create(:client, user: user)}
    before do
      visit client_path(client)
      click_button 'Accept'
    end
    scenario 'has new case note link' do
      expect(page).to have_link('Add EC', href: new_client_case_path(client, case_type: 'EC'))
      expect(page).to have_link('Add FC', href: new_client_case_path(client, case_type: 'FC'))
      expect(page).to have_link('Add KC', href: new_client_case_path(client, case_type: 'KC'))
    end
  end

  context 'Reject' do
    let!(:client){create(:client, user: user)}
    before do
      visit client_path(client)
      fill_in 'Note', with: FFaker::Lorem.paragraph
      find('input[type="submit"][value="Reject"]').click
    end
    scenario 'successfully' do
      expect(page).to have_content('Client has been successfully updated')
    end
  end

end
