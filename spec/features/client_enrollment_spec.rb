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
    let!(:tracking) { create(:tracking, client_enrollment: client_enrollment, program_stream: second_program_stream) }
    let!(:leave_program) { create(:leave_program, client_enrollment: client_enrollment, program_stream: second_program_stream)}

    before do
      visit report_client_client_enrollments_path(client, program_stream_id: program_stream)
    end

    scenario 'List Tracking' do
      expect(page).to have_content(program_stream.created_at.strftime '%d %B, %Y')
      expect(page).to have_content('Tracking')
      expect(page).to have_link('View')
    end

    scenario 'List Exit' do
      expect(page).to have_content(program_stream.created_at.strftime '%d %B, %Y')
      expect(page).to have_content('Exit')
      expect(page).to have_link('View')
    end
  end

  feature 'Show' do
    before do
      visit client_client_enrollment_path(client, client_enrollment, program_stream_id: program_stream)
    end

    scenario 'Age' do
      expect(page).to have_content("age")
    end

    scenario 'Email' do
      expect(page).to have_content("e-mail")
    end
    
    scenario 'Description' do
      expect(page).to have_content("description")
    end

    scenario 'Back Link' do
      expect(page).to have_link("Back")
    end
  end
end