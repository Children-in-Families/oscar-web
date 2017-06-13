describe ClientEnrollmentTracking, 'Client Enrollment Tracking' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:client) { create(:client, date_of_birth: 10.years.ago) }
  let!(:program_stream) { create(:program_stream) }
  let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream, client: client) }
  let!(:tracking) { create(:tracking, program_stream: program_stream) }
  let!(:client_enrollment_tracking) { create(:client_enrollment_tracking, client_enrollment: client_enrollment, tracking: tracking) }

  before do
    login_as admin
  end

  feature 'Create', js: true do
    before do 
      visit client_client_enrollments_path(client)
      click_link('Tracking')
    end

    scenario 'Valid' do
      click_link('New Tracking')
      within('#new_client_enrollment_tracking') do
        find('.numeric').set(4)
        find('input[type="text"]').set('Good client')
        find('input[type="email"]').set('cif@cambodianfamilies.com')
        
        click_button 'Save'
      end
      expect(page).to have_content('Tracking Program has been successfully created')
    end

    scenario 'Invalid' do
      click_link('New Tracking')
      within('#new_client_enrollment_tracking') do
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

  feature 'Lists' do
    before do
      visit client_client_enrollment_client_enrollment_trackings_path(client, client_enrollment)
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
      visit report_client_client_enrollment_client_enrollment_trackings_path(client, client_enrollment, tracking_id: tracking.id)
    end

    scenario 'Age' do
      expect(page).to have_content('3')
    end

    scenario 'E-mail' do
      expect(page).to have_content('cif@cambodianfamily.com')
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
      expect(page).to have_link(nil, edit_client_client_enrollment_client_enrollment_tracking_path(client, client_enrollment, client_enrollment_tracking))
    end

    scenario 'Destroy Link' do
      expect(page).to have_css("a[href='#{client_client_enrollment_client_enrollment_tracking_path(client, client_enrollment, client_enrollment_tracking, tracking_id: tracking.id)}'][data-method='delete']")
    end
  end

  feature 'Show' do
    before do
      visit client_client_enrollment_client_enrollment_tracking_path(client, client_enrollment, client_enrollment_tracking)
    end

    scenario 'Age' do
      expect(page).to have_content('3')
    end

    scenario 'E-mail' do
      expect(page).to have_content('cif@cambodianfamily.com')
    end

    scenario 'Description' do
      expect(page).to have_content('this is testing')
    end

    scenario 'Back Link' do
      expect(page).to have_link('Back')
    end

    scenario 'Client Tracking Link' do

      expect(page).to have_link('Client Trackings List')
    end
  end

  feature 'Update', js: true do
    before do
      visit edit_client_client_enrollment_client_enrollment_tracking_path(client, client_enrollment, client_enrollment_tracking, tracking_id: tracking.id)
    end

    scenario 'success' do
      find('input[type="text"]').set('this is editing')
      find('input[type="submit"]').click
      expect(page).to have_content('Tracking Program has been successfully updated')
    end

    scenario 'fail' do
      find('input[type="text"]').set('')
      find('input[type="submit"]').click
      expect(page).to have_content("description can't be blank")
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
end