describe 'Client Enrollment' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:client) { create(:client, date_of_birth: 10.years.ago) }
  let!(:domain) { create(:domain) }
  let!(:program_stream) { create(:program_stream) }
  let!(:domain_program_stream) { create(:domain_program_stream, domain: domain, program_stream: program_stream) }

  let!(:second_program_stream) { create(:program_stream, name: 'second name') }
  let!(:client_enrollment) { create(:client_enrollment, program_stream: second_program_stream, client: client) }

  let!(:third_program_stream) { create(:program_stream, name: 'third name') }
  let!(:exit_client_enrollment) { create(:client_enrollment, program_stream: third_program_stream, client: client, status: 'Exited') }
  let!(:leave_program) { create(:leave_program, client_enrollment: exit_client_enrollment, program_stream: third_program_stream) }

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
      expect(page).to have_link('Enroll', href: new_client_client_enrollment_path(client,program_stream_id: program_stream))
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
      expect(page).to have_content('Exited')
    end
  end

  feature 'Enroll' do
    before do
      visit client_client_enrollments_path(client)
      page.click_link('Enroll', href: new_client_client_enrollment_path(client, program_stream_id: program_stream))
    end

    scenario 'Create', js: true do
      within('#new_client_enrollment') do
        find('.numeric').set(3)
        find('input[type="text"]').set('this is testing')
        find('input[type="email"]').set('cif@cambodianfamilies.com')
        
        click_button 'Save'
      end
      expect(page).to have_content('Enrollment has been successfully created')
    end
  end

  

end