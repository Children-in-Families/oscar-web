describe ClientEnrollmentTracking, 'Client Enrollment Tracking' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:user) { create(:user) }
  let!(:client) { create(:client, :accepted, given_name: 'Adam', family_name: 'Eve', local_given_name: 'Juliet', local_family_name: 'Romeo', date_of_birth: 10.years.ago, users: [admin, user]) }
  let!(:program_stream) { create(:program_stream, name: 'Fitness') }
  let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream, client: client) }
  let!(:tracking) { create(:tracking, name: 'Soccer', program_stream: program_stream) }
  let!(:client_enrollment_tracking) { create(:client_enrollment_tracking, client_enrollment: client_enrollment, tracking: tracking) }

  feature 'Create', js: true do
    before do
      login_as admin
      program_stream.reload
      program_stream.update_columns(completed: true)
      visit client_client_enrolled_programs_path(client)
      click_link('Trackings')
    end

    scenario 'Valid', js: true do
      click_link('New Tracking')
      expect(page).to have_content('Adam Eve (Romeo Juliet) - Soccer - Fitness')
      within('#new_client_enrollment_tracking') do
        find('.numeric').set(4)
        find('input[type="text"]').set('Good client')
        find('input[type="email"]').set('test@example.com')

        click_button 'Save'
      end
      expect(page).to have_content('Good client')
      expect(page).to have_content('test@example.com')
    end

    scenario 'Invalid' do
      click_link('New Tracking')
      expect(page).to have_content('Adam Eve (Romeo Juliet) - Soccer - Fitness')
      within('#new_client_enrollment_tracking') do
        find('.numeric').set(6)
        find('input[type="text"]').set('')
        find('input[type="email"]').set('cicambodianfamilies')

        click_button 'Save'
      end
      expect(page).to have_css('div.form-group.has-error')
    end
  end

  feature 'Lists' do
    before do
      login_as admin
      visit client_client_enrolled_program_client_enrolled_program_trackings_path(client, client_enrollment)
    end

    scenario 'Name' do
      expect(page).to have_content(tracking.name)
    end

    scenario 'Program lists link' do
      expect(page).to have_link('Programs List')
    end

    scenario 'Report link' do
      expect(page).to have_link('View')
    end

    scenario 'New tracking link' do
      expect(page).to have_link('New Tracking')
    end
  end

  feature 'Report' do
    before do
      login_as admin
      visit report_client_client_enrolled_program_client_enrolled_program_trackings_path(client, client_enrollment, tracking_id: tracking.id)
    end

    scenario 'Age' do
      expect(page).to have_content('3')
    end

    scenario 'E-mail' do
      expect(page).to have_content('test@example.com')
    end

    scenario 'Description' do
      expect(page).to have_content('this is testing')
    end

    scenario 'Back Link' do
      expect(page).to have_link('Back')
    end

    scenario 'New Tracking Link' do
      expect(page).to have_link('New Tracking')
    end

    scenario 'Edit Link' do
      expect(page).to have_link(nil, edit_client_client_enrolled_program_client_enrolled_program_tracking_path(client, client_enrollment, client_enrollment_tracking))
    end

    scenario 'Destroy Link' do
      expect(page).to have_css("a[href='#{client_client_enrolled_program_client_enrolled_program_tracking_path(client, client_enrollment, client_enrollment_tracking, tracking_id: tracking.id)}'][data-method='delete']")
    end
  end

  feature 'Show' do
    before do
      PaperTrail::Version.where(event: 'create', item_type: 'ClientEnrollmentTracking', item_id: client_enrollment_tracking.id).update_all(whodunnit: admin.id)
      login_as admin
      visit client_client_enrollment_client_enrollment_tracking_path(client, client_enrollment, client_enrollment_tracking, tracking_id: tracking.id)
    end

    scenario 'Created by .. on ..' do
      user = whodunnit_client_enrollment_tracking(client_enrollment_tracking.id)
      date = date_format(client_enrollment_tracking.created_at)
      sleep 1
      expect(page).to have_content("Created by #{user} on #{date}")
    end

    scenario 'Age' do
      expect(page).to have_content('3')
    end

    scenario 'E-mail' do
      expect(page).to have_content('test@example.com')
    end

    scenario 'Description' do
      expect(page).to have_content('this is testing')
    end

    scenario 'Back Link' do
      expect(page).to have_link('Back')
    end
  end

  feature 'Update', js: true do
    before do
      login_as admin
      client.reload
      visit edit_client_client_enrolled_program_client_enrolled_program_tracking_path(client, client_enrollment, client_enrollment_tracking, tracking_id: tracking.id)
    end

    scenario 'success' do
      expect(page).to have_content('Adam Eve (Romeo Juliet) - Soccer - Fitness')
      find('input[type="text"]').set('this is editing')
      find('input[type="submit"]').click
      expect(page).to have_content('this is editing')
    end

    xscenario 'fail' do
      expect(page).to have_content('Adam Eve (Romeo Juliet) - Soccer - Fitness')
      find('input[type="text"]').set('')
      find('input[type="submit"]').click
      expect(page).to have_css('div.has-error')
    end
  end

  # feature 'Destroy', js: true do
  #   before do
  #     visit client_client_enrollment_client_enrollment_tracking_path(client, client_enrollment, client_enrollment_tracking, tracking_id: tracking.id)
  #   end

  #   scenario 'success' do
  #     save_and_open_screenshot
  #     find("a[data-method='delete'][href='#{client_client_enrollment_client_enrollment_tracking_path(client, client_enrollment, client_enrollment_tracking, tracking_id: tracking.id)}']").click
  #     save_and_open_screenshot
  #     expect(page).to have_content('Tracking has been successfully deleted')
  #   end
  # end

  feature 'Program stream permissions' do
    let!(:first_program_stream) { create(:program_stream, name: 'first') }
    let!(:first_tracking) { create(:tracking, name: 'first tracking', program_stream: first_program_stream) }
    let!(:first_client_enrollment) { create(:client_enrollment, program_stream: first_program_stream, client: client) }
    let!(:first_client_enrollment_tracking) { create(:client_enrollment_tracking, client_enrollment: first_client_enrollment, tracking: first_tracking) }

    before do
      login_as user
    end

    context 'user has readable/ does not have permission' do
      scenario 'can read client enrollment tracking' do
        show_path = client_client_enrolled_program_client_enrolled_program_tracking_path(client, first_client_enrollment, first_client_enrollment_tracking)
        visit show_path
        expect(show_path).to have_content(current_path)
      end

      scenario 'cannot read client enrollment tracking' do
        show_path = client_client_enrolled_program_client_enrolled_program_tracking_path(client, first_client_enrollment, first_client_enrollment_tracking)
        user.program_stream_permissions.find_by(program_stream_id: first_program_stream.id).update(readable: false)
        visit show_path
        expect(dashboards_path).to have_content(current_path)
      end
    end

    context 'user has editable permission' do
      scenario 'new client enrollment traking' do
        new_path = new_client_client_enrolled_program_client_enrolled_program_tracking_path(client, first_client_enrollment, tracking_id: first_tracking.id)
        visit new_path
        expect(new_path).to have_content(current_path)
      end

      scenario 'edit client enrollment tracking' do
        edit_path = edit_client_client_enrollment_client_enrollment_tracking_path(client, first_client_enrollment, first_client_enrollment_tracking, tracking_id: tracking.id)
        visit edit_path
        expect(edit_path).to have_content(current_path)
      end
    end

    context 'user dose not have editable permission' do
      scenario 'new client enrollment tracking' do
        new_path = new_client_client_enrolled_program_client_enrolled_program_tracking_path(client, first_client_enrollment, tracking_id: first_tracking.id)
        user.program_stream_permissions.find_by(program_stream_id: first_program_stream.id).update(editable: false)
        visit new_path
        expect(dashboards_path).to have_content(current_path)
      end

      scenario 'edit client enrollment tracking' do
        edit_path = edit_client_client_enrollment_client_enrollment_tracking_path(client, first_client_enrollment, first_client_enrollment_tracking, tracking_id: tracking.id)
        user.program_stream_permissions.find_by(program_stream_id: first_program_stream.id).update(editable: false)
        visit edit_path
        expect(edit_path).to have_content(current_path)
      end
    end
  end
end

def whodunnit_client_enrollment_tracking(id)
  user_id = PaperTrail::Version.find_by(event: 'create', item_type: 'ClientEnrollmentTracking', item_id: id).try(:whodunnit)
  return 'OSCaR Team' if user_id.present? && user_id.include?('@rotati')
  User.find_by(id: user_id).try(:name) || ''
end
