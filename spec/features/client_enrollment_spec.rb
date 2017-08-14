describe 'Client Enrollment' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:client) { create(:client, given_name: 'Adam', family_name: 'Eve', local_given_name: 'Romeo', local_family_name: 'Juliet', date_of_birth: 10.years.ago) }
  let!(:domain) { create(:domain) }
  let!(:program_stream) { create(:program_stream, name: 'Fitness') }
  let!(:program_stream_active) { create(:program_stream, name: 'Second Fitness') }
  let!(:program_stream_exited) { create(:program_stream, name: 'Third Fitness') }
  let!(:domain_program_stream) { create(:domain_program_stream, domain: domain, program_stream: program_stream) }
  let!(:domain_program_stream_exited) { create(:domain_program_stream, domain: domain, program_stream: program_stream_exited) }
  let!(:domain_program_stream_active) { create(:domain_program_stream, domain: domain, program_stream: program_stream_active) }

  let!(:second_program_stream) { create(:program_stream, name: 'second name') }
  let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream, client: client) }
  let!(:client_enrollment_active) { create(:client_enrollment, program_stream: program_stream_active, client: client, status: 'Active') }
  let!(:client_enrollment_exited) { create(:client_enrollment, program_stream: program_stream_exited, client: client, status: 'Exited') }

  before do
    login_as admin
  end

  feature 'List client enrollment status active' do
    before do
      program_stream_active.reload
      program_stream_active.update_columns(completed: true)

      visit client_client_enrolled_programs_path(client)
    end

    scenario 'program lists' do
      expect(page).to have_content('Adam Eve (Romeo Juliet) - Programs List')
    end

    scenario 'program name' do
      expect(page).to have_content(program_stream.name)
    end

    scenario 'quantity' do
      expect(page).to have_content('9')
    end

    scenario 'domain' do
      expect(page).to have_content(program_stream.domains.pluck(:identity).join(', '))
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
  end

  feature 'List client enrollment not status active' do
    before do
      program_stream_exited.reload
      program_stream_exited.update_columns(completed: true)

      visit client_client_enrollments_path(client)
    end

    scenario 'program lists' do
      expect(page).to have_content('Adam Eve (Romeo Juliet) - Programs List')
    end

    scenario 'program name' do
      expect(page).to have_content(program_stream.name)
    end

    scenario 'quantity' do
      expect(page).to have_content('10')
    end

    scenario 'domain' do
      expect(page).to have_content(program_stream.domains.pluck(:identity).join(', '))
    end

    scenario 'enroll link' do
      expect(page).to have_link('Enroll')
    end

    scenario 'exit status' do
      client_enrollment.update_columns(status: 'Exited')
      expect(client_enrollment.status).to have_content('Exited')
    end
  end

  feature 'Enroll', js: true do
    before do
      program_stream.reload
      program_stream.update_columns(completed: true)

      second_program_stream.reload
      second_program_stream.update_columns(completed: true)
      visit client_client_enrollments_path(client)
      click_link('Enroll')
    end

    scenario 'Valid' do
      within('#new_client_enrollment') do
        find('.numeric').set(3)
        find('#enrollment_date').set(FFaker::Time.date)
        find('#client_enrollment_properties_description').set('this is testing')
        find('input[type="email"]').set('test@example.com')

        click_button 'Save'
      end
      expect(page).to have_content('Enrollment has been successfully created')
    end

    scenario 'Invalid' do
      within('#new_client_enrollment') do
        find('.numeric').set(6)
        find('#client_enrollment_properties_description').set('')
        find('input[type="email"]').set('testexample')

        click_button 'Save'
      end
      expect(page).to have_css('div.form-group.has-error')
    end
  end

  feature 'Report' do
    let!(:tracking) { create(:tracking, program_stream: second_program_stream) }

    before do
      visit report_client_client_enrolled_programs_path(client, program_stream_id: program_stream)
    end

    scenario 'Date' do
      expect(page).to have_content(client_enrollment.enrollment_date.strftime '%d %B, %Y')
      expect(page).to have_content(client_enrollment_active.enrollment_date.strftime '%d %B, %Y')
      expect(page).to have_content(client_enrollment_exited.enrollment_date.strftime '%d %B, %Y')
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
      visit client_client_enrolled_program_path(client, client_enrollment, program_stream_id: program_stream.id)
    end

    scenario 'Date' do
      expect(page).to have_content(client_enrollment.enrollment_date.strftime '%d %B, %Y')
    end

    scenario 'Age' do
      expect(page).to have_content('3')
    end

    scenario 'Email' do
      expect(page).to have_content('test@example.com')
    end

    scenario 'Description' do
      expect(page).to have_content('this is testing')
    end

    scenario 'Back Link' do
      expect(page).to have_link('Back')
    end

    scenario 'Edit Link' do
      expect(page).to have_link(nil, edit_client_client_enrolled_program_path(client, client_enrollment, program_stream_id: program_stream.id))
    end

    # xscenario 'Delete Link' do
    #   expect(page).to have_css("a[href='#{client_client_enrollment_path(client, client_enrollment, program_stream_id: program_stream.id)}'][data-method='delete']")
    # end
  end

  feature 'Update', js: true do
    before do
      visit edit_client_client_enrolled_program_path(client, client_enrollment, program_stream_id: program_stream.id)
    end

    scenario 'success' do
      find('input[type="text"]:last-child').set('this is editing')
      find('input[type="submit"]').click
      expect(page).to have_content('Enrollment has been successfully updated')
    end

    scenario 'fail' do
      find('input[type="text"]:last-child').set('')
      find('input[type="submit"]').click
      expect(page).to have_css('div.form-group.has-error')
    end
  end

  # xfeature 'Destroy', js: true do
  #   before do
  #     visit client_client_enrollment_path(client, client_enrollment, program_stream_id: program_stream.id)
  #   end
  #
  #   scenario 'success' do
  #     find("a[data-method='delete'][href='#{client_client_enrollment_path(client, client_enrollment, program_stream_id: program_stream.id)}']").click
  #     expect(page).to have_content('Enrollment has been successfully deleted.')
  #   end
  # end
end
