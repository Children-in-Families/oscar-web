describe 'Client Enrollment' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:user) { create(:user) }
  let!(:client) { create(:client, :accepted, given_name: 'Adam', family_name: 'Eve', local_given_name: 'Juliet', local_family_name: 'Romeo', date_of_birth: 10.years.ago, users: [admin, user]) }
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

  feature 'List client enrollment status active' do
    let!(:user) { create(:user) }
    before do
      login_as admin

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
      login_as admin
      program_stream_exited.reload
      program_stream_exited.update_columns(completed: true)

      visit client_client_enrollments_path(client)
    end

    scenario 'program lists', js:true do
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
      login_as admin
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
      expect(page).to have_content('3')
      expect(page).to have_content('this is testing')
      expect(page).to have_content('test@example.com')
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
      login_as admin
      visit report_client_client_enrolled_programs_path(client, program_stream_id: program_stream)
    end

    scenario 'Date' do
      expect(page).to have_content(date_format(client_enrollment.enrollment_date))
      expect(page).to have_content(date_format(client_enrollment_active.enrollment_date))
      expect(page).to have_content(date_format(client_enrollment_exited.enrollment_date))
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
      login_as admin
      visit client_client_enrolled_program_path(client, client_enrollment, program_stream_id: program_stream.id)
    end

    scenario 'Date' do
      expect(page).to have_content(date_format(client_enrollment.enrollment_date))
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
      login_as admin
      visit edit_client_client_enrolled_program_path(client, client_enrollment, program_stream_id: program_stream.id)
    end

    scenario 'success' do
      find('input[type="text"]:last-child').set('this is editing')
      find('input[type="submit"]').click
      expect(page).to have_content('this is editing')
    end

    scenario 'fail' do
      find('input[type="text"]:last-child').set('')
      find('input[type="submit"]').click
      expect(page).to have_css('div.form-group.has-error')
    end
  end

  feature 'Destroy', js: true do
    before do
      login_as admin
      visit client_client_enrollment_path(client, client_enrollment, program_stream_id: program_stream.id)
    end

    scenario 'success' do
      find("a[data-method='delete'][href='#{client_client_enrollment_path(client, client_enrollment, program_stream_id: program_stream.id)}']").click
      expect(page).not_to have_content(date_format(client_enrollment.enrollment_date))
    end
  end

  feature 'Program streams permission' do
    let!(:first_program_stream) { create(:program_stream, name: 'First', completed: true) }
    let!(:another_program_stream) { create(:program_stream, name: 'Second') }
    let!(:client_enrollment) { create(:client_enrollment, program_stream: another_program_stream, client: client) }
    let!(:client_enrollment_exited) { create(:client_enrollment, program_stream: first_program_stream, client: client, status: 'Exited') }

    before do
      login_as user
    end

    context 'user has readable permission' do
      scenario 'index client enrollments' do
        first_program_stream.reload
        first_program_stream.update_columns(completed: true)
        visit client_client_enrollments_path(client)
        expect(page).to have_content(first_program_stream.name)
      end

      scenario 'index client enrolled programs' do
        another_program_stream.reload
        another_program_stream.update_columns(completed: true)

        visit client_client_enrolled_programs_path(client)
        expect(page).to have_content(another_program_stream.name)
      end
    end

    context 'user does not have readable permission' do
      scenario 'client enrollment index page' do
        first_program_stream.reload
        first_program_stream.update_columns(completed: true)
        user.program_stream_permissions.find_by(program_stream_id: first_program_stream.id).update(readable: false)
        visit client_client_enrollments_path(client)
        expect(page).not_to have_content(first_program_stream.name)
      end

      scenario 'client enrolled program index page' do
        another_program_stream.reload
        another_program_stream.update_columns(completed: true)
        user.program_stream_permissions.find_by(program_stream_id: another_program_stream.id).update(readable: false)

        visit client_client_enrolled_programs_path(client)
        expect(page).not_to have_content(another_program_stream.name)
      end
    end

    context 'user has editable permission' do
      scenario 'edit client enrollment' do
        edit_path = edit_client_client_enrollment_path(client, client_enrollment, program_stream_id: first_program_stream.id)
        visit edit_path
        expect(edit_path).to have_content(current_path)
      end

      scenario 'new client enrollment' do
        new_path = new_client_client_enrollment_path(client, program_stream_id: first_program_stream.id)
        visit new_path
        expect(new_path).to have_content(current_path)
      end

      scenario 'edit client enrolled program' do
        edit_path = edit_client_client_enrolled_program_path(client, client_enrollment, program_stream_id: another_program_stream.id)
        visit edit_path
        expect(edit_path).to have_content(current_path)
      end
    end

    context 'user does not have editable permission' do
      scenario 'edit client enrollment' do
        user.program_stream_permissions.find_by(program_stream: first_program_stream.id).update(editable: false)
        edit_path = edit_client_client_enrollment_path(client, client_enrollment, program_stream_id: first_program_stream.id)
        visit edit_path
        expect(dashboards_path).to have_content(current_path)
      end

      scenario 'new client enrollment' do
        user.program_stream_permissions.find_by(program_stream: first_program_stream.id).update(editable: false)
        new_path = new_client_client_enrollment_path(client, program_stream_id: first_program_stream.id)
        visit new_path
        expect(dashboards_path).to have_content(current_path)
      end

      scenario 'edit client enrolled program' do
        user.program_stream_permissions.find_by(program_stream: another_program_stream.id).update(editable: false)
        edit_path = edit_client_client_enrolled_program_path(client, client_enrollment, program_stream_id: another_program_stream.id)
        visit edit_path
        expect(dashboards_path).to have_content(current_path)
      end
    end
  end
end
