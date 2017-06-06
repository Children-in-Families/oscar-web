describe LeaveProgram, 'Leave Program' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:client) { create(:client, date_of_birth: 10.years.ago) }
  let!(:program_stream) { create(:program_stream) }
  let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream, client: client) }

  before do
    login_as admin
  end

  feature 'Create', js: true do
    before do 
      visit client_client_enrollments_path(client)
      click_link('Exit')
    end

    scenario 'Valid' do
      within('#new_leave_program') do
        find('.numeric').set(4)
        find('input[type="text"]').set('Good client')
        find('input[type="email"]').set('cif@cambodianflamilies.com')

        click_button 'Save'
      end
      expect(page).to have_content('Client has successfully exited from the program')
    end

    scenario 'Invalid' do
      within('#new_leave_program') do
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
end