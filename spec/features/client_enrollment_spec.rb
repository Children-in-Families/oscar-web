describe 'Client Enrollment' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:client) { create(:client, date_of_birth: 10.years.ago) }
  let!(:domain) { create(:domain) }
  let!(:program_stream) { create(:program_stream) }
  let!(:domain_program_stream) { create(:domain_program_stream, domain: domain, program_stream: program_stream) }

  let!(:second_program_stream) { create(:program_stream, name: 'second name') }
  let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream, client: client) }

  
  before do
    login_as admin
  end

  feature 'List' do
    before do
      visit client_client_enrollments_path(client)
    end

    scenario 'program name' do
      expect(page).to have_content(program_stream.name)
    end

    scenario 'domain' do
      expect(page).to have_content(program_stream.domains.pluck(:identity).join(', '))
    end

    scenario 'enroll link' do
      expect(page).to have_link('Enroll')
    end

    scenario 'exit link' do
      expect(page).to have_link('Exit')
    end

    scenario 'tracking link' do
      expect(page).to have_link('Tracking')
    end

    scenario 'active status' do
      expect(page).to have_content('Active')
    end

    scenario 'exit status' do
      client_enrollment.update_columns(status: 'Exited')
      expect(client_enrollment.status).to have_content('Exited')
    end
  end

  feature 'Enroll', js: true do
    before do
      visit client_client_enrollments_path(client)
      click_link('Enroll')
    end

    scenario 'Valid' do
      within('#new_client_enrollment') do
        find('.numeric').set(3)
        find('input[type="text"]').set('this is testing')
        find('input[type="email"]').set('cif@cambodianfamilies.com')
        
        click_button 'Save'
      end
      expect(page).to have_content('Enrollment has been successfully created')
    end

    scenario 'Invalid' do
      within('#new_client_enrollment') do
        find('.numeric').set(6)
        find('input[type="text"]').set('')
        find('input[type="email"]').set('cicambodianfamilies')
        
        click_button 'Save'
      end
      expect(page).to have_content('is not an email')
      expect(page).to have_content("can't be greater than 5")
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Report' do
    let!(:tracking) { create(:tracking, program_stream: second_program_stream) }

    before do
      visit report_client_client_enrollments_path(client, program_stream_id: program_stream)
    end

    scenario 'Date' do
      expect(page).to have_content(program_stream.created_at.strftime '%d %B, %Y')
    end

    scenario 'View Link' do
      expect(page).to have_link('View')
    end

    scenario 'Program List Link' do
      expect(page).to have_link('Programs List')
    end
  end

  feature 'Show' do
    before do
      visit client_client_enrollment_path(client, client_enrollment, program_stream_id: program_stream.id)
    end

    scenario 'Date' do
      expect(page).to have_content(client_enrollment.created_at.strftime '%d %B, %Y')
    end

    scenario 'Age' do
      expect(page).to have_content('3')
    end

    scenario 'Email' do
      expect(page).to have_content('cif@cambodianfamily.com')
    end

    scenario 'Description' do
      expect(page).to have_content('this is testing')
    end

    scenario 'Back Link' do
      expect(page).to have_link('Back')
    end

    scenario 'Edit Link' do
      expect(page).to have_link(nil, edit_client_client_enrollment_path(client, client_enrollment, program_stream_id: program_stream.id))
    end

    scenario 'Delete Link' do
      expect(page).to have_css("a[href='#{client_client_enrollment_path(client, client_enrollment, program_stream_id: program_stream.id)}'][data-method='delete']")
    end
  end

  feature 'Update', js: true do
    before do
      visit edit_client_client_enrollment_path(client, client_enrollment, program_stream_id: program_stream.id)
    end

    scenario 'success' do
      find('input[type="text"]').set('this is editing')
      find('input[type="submit"]').click
      expect(page).to have_content('Enrollment has been successfully updated')
    end

    scenario 'fail' do
      find('input[type="text"]').set('')
      find('input[type="submit"]').click
      expect(page).to have_content("description can't be blank")
    end
  end

  feature 'Destroy', js: true do
    before do
      visit client_client_enrollment_path(client, client_enrollment, program_stream_id: program_stream.id)
    end

    scenario 'success' do
      find("a[data-method='delete'][href='#{client_client_enrollment_path(client, client_enrollment, program_stream_id: program_stream.id)}']").click
      expect(page).to have_content('Enrollment has been successfully deleted.')
    end
  end
end