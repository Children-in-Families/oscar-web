feature 'program_stream' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:domain) { create(:domain) }
  let!(:program_stream) { create(:program_stream, ngo_name: Organization.current.full_name) }
  let!(:program_stream_search) { create(:program_stream, ngo_name: Organization.current.full_name, name: 'Program Stream Search') }
  let!(:custom_field) { create(:custom_field, ngo_name: Organization.current.full_name) }
  let!(:tracking) { create(:tracking, program_stream: program_stream) }
  let!(:domain_program_stream){ create(:domain_program_stream, domain: domain, program_stream: program_stream) }

  before do
    Organization.switch_to 'demo'
    ProgramStream.create(name: 'Other NGO Program Stream')
    Organization.switch_to 'app'
    login_as(admin)
  end

  feature 'list' do
    before do
      visit program_streams_path
    end

    scenario 'name' do
      expect(page).to have_content(program_stream.name)
    end

    scenario 'domain' do
      expect(page).to have_content(program_stream.domains.pluck(:identity).join(', '))
    end

    scenario 'status' do
      expect(page).to have_content('Incompleted')
    end

    scenario 'quantity' do
      expect(page).to have_content(program_stream.quantity)
    end

    scenario 'new link' do
      expect(page).to have_link('Add New Program', href: new_program_stream_path)
    end

    scenario 'edit link' do
      expect(page).to have_link(nil, href: edit_program_stream_path(program_stream))
    end

    scenario 'delete link' do
      expect(page).to have_css("a[href='#{program_stream_path(program_stream)}'][data-method='delete']")
    end

    scenario 'show link' do
      expect(page).to have_link(nil, href: program_stream_path(program_stream))
    end

    scenario 'list my ngo program strams', js: true do
      find('a[href="#current-program-streams"]').click
      expect(page).to have_content(program_stream.name)
    end

    scenario 'list all ngo program streams', js: true do
      find('a[href="#ngos-program-streams"]').click
      expect(page).to have_content(program_stream.name)
    end

    scenario 'list demo ngo program streams', js: true do
      find('a[href="#demo-program-streams"]').click
      expect(page).to have_content('Other NGO Program Stream')
    end
  end

  feature 'show' do
    before do
      visit program_stream_path(program_stream)
    end

    scenario 'name' do
      expect(page).to have_content(program_stream.name)
    end

    scenario 'status' do
      expect(page).to have_content(program_stream.decorate.completed_status)
    end

    scenario 'description' do
      expect(page).to have_content(program_stream.description)
    end

    scenario 'domains' do
      expect(page).to have_content(program_stream.domains.pluck(:identity).join(', '))
    end

    scenario 'quantity' do
      expect(page).to have_content(program_stream.quantity)
    end

    scenario 'rules' do
      expect(page).to have_content('Age')
    end

    scenario 'enrollment' do
      expect(page).to have_content('e-mail')
    end

    scenario 'tracking' do
      expect(page).to have_content('e-mail')
    end

    scenario 'leave_program' do
      expect(page).to have_content('e-mail')
    end

    scenario 'edit link' do
      expect(page).to have_link(nil, href: edit_program_stream_path(program_stream))
    end

    scenario 'back link' do
      expect(page).to have_link(nil, href: program_streams_path)
    end
  end

  feature 'create', js: true do
    before do
      visit program_streams_path
      page.click_link 'Add New Program'
    end

    context 'full step creation' do
      xscenario 'valid' do
        fill_in 'program_stream_name', with: 'Program Name'
        sleep 1
        click_link 'Next'
        page.find(".rule-filter-container select option[value='gender']", visible: false).select_option
        expect(page).to have_content 'Gender'

        page.click_link 'Next'
        sleep 1
        page.find('li[data-type="date"]').click
        page.click_link 'Next'
        sleep 1
        within('#trackings') do
          fill_in 'Name', with: 'Tracking Name'
        end
        page.find('li[data-type="text"]').click
        page.click_link 'Next'
        sleep 1
        page.find('li[data-type="textarea"]').click
        page.click_link 'Save'
        expect(page).to have_content('Program Name')
      end

      xscenario 'invalid' do
        page.click_link 'Next'
        expect(page).to have_css '.error'
      end
    end

    context 'save draft' do
      xscenario 'valid' do
        fill_in 'program_stream_name', with: 'Save Draft'
        find('span', text: 'Save').click
        expect(page).to have_content('Program Detail')
        expect(page).to have_content('Save Draft')
        expect(page).to have_content('Rules')
        expect(page).to have_content('Enrollment')
        expect(page).to have_content('Tracking')
        expect(page).to have_content('Exit Program')
      end

      scenario 'invalid' do
        page.click_link 'Next'
        expect(page).to have_css '.error'
      end
    end

  end

  feature 'edit', js: true  do
    before do
      visit program_streams_path
      expect(page).to have_link(nil, href: edit_program_stream_path(program_stream))
      click_link(nil, href: edit_program_stream_path(program_stream))
    end

    scenario 'title of current program stream' do
      expect(page).to have_content("Edit #{program_stream.name}")
    end

    context 'full step' do
      xscenario 'valid' do
        page.click_link 'Next'
        sleep 1
        page.click_link 'Next'
        sleep 1
        page.click_link 'Next'
        sleep 1
        page.click_link 'Next'
        sleep 1
        page.click_link 'Save'
        expect(page).to have_content('Program Stream has been successfully updated.')
      end

      scenario 'invalid' do
        fill_in 'program_stream_name', with: ''
        page.click_link 'Next'
        expect(page).to have_css '.error'
      end
    end

    context 'save draft' do
      xscenario 'valid' do
        find('span', text: 'Save').click
        expect(page).to have_content(program_stream.name)
      end

      scenario 'invalid' do
        fill_in 'program_stream_name', with: ''
        page.click_link 'Next'
        expect(page).to have_css '.error'
      end
    end
  end

  feature 'Delete', js: true do
    let!(:client_progrm_stream) { create(:client, users: [admin]) }
    let!(:program_stream_1) { create(:program_stream, ngo_name: Organization.current.full_name) }
    let!(:program_stream_2) { create(:program_stream, ngo_name: Organization.current.full_name) }
    let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream_1, client: client_progrm_stream) }
    let!(:client_enrollment_2) { create(:client_enrollment, program_stream: program_stream_2, client: client_progrm_stream) }
    let!(:client_enrollment_tracking) { create(:client_enrollment_tracking, client_enrollment: client_enrollment) }
    let!(:leave_program) { create(:leave_program, program_stream: program_stream_1, client_enrollment: client_enrollment) }

    before do
      visit program_streams_path
    end

    scenario 'delete successfully' do
      find("a[href='#{program_stream_path(program_stream)}'][data-method='delete']").click
      expect(page).not_to have_content(program_stream.name)
    end

    xscenario 'can delete program stream has been exited' do
      find("a[href='#{program_stream_path(program_stream_1)}'][data-method='delete']").click
      expect(page).not_to have_content(program_stream_1.name)
    end

    scenario 'cannot delete program stream has been enrolled' do
      expect(page).not_to have_css("a[href='#{program_stream_path(program_stream_2)}'][data-method='delete']")
    end
  end

  feature 'Copy', js: true do
    before do
      visit program_streams_path
    end

    xscenario 'valid' do
      click_link "All NGOs' Program Streams"
      all_ngos = find('#ngos-program-streams')
      all_ngos.click_link(nil, href: new_program_stream_path(program_stream_id: program_stream.id, ngo_name: program_stream.ngo_name))
      fill_in 'program_stream_name', with: 'Program Copy'
      click_link 'Next'
      sleep 1
      click_link 'Next'
      sleep 1
      click_link 'Next'
      sleep 1
      click_link 'Next'
      sleep 1
      click_link 'Save'

      expect(page).to have_content('Program Copy')
    end

    scenario 'invalid' do
      click_link "All NGOs' Program Streams"
      all_ngos = find('#ngos-program-streams')
      all_ngos.click_link(nil, href: new_program_stream_path(program_stream_id: program_stream.id, ngo_name: program_stream.ngo_name))
      fill_in 'program_stream_name', with: ''
      click_link 'Next'

      expect(page).to have_css '.error'
    end
  end

  feature 'Preview Other NGOs' do
    before do
      visit program_streams_path
      click_link "All NGOs' Program Streams"
      all_ngos = find('#ngos-program-streams')
      all_ngos.click_link(nil, href: preview_program_streams_path(program_stream_id: program_stream.id, ngo_name: program_stream.ngo_name))
    end

    scenario 'name' do
      expect(page).to have_content(program_stream.name)
    end

    scenario 'description' do
      expect(page).to have_content(program_stream.description)
    end

    scenario 'domains' do
      expect(page).to have_content(program_stream.domains.pluck(:identity).join(', '))
    end

    scenario 'quantity' do
      expect(page).to have_content(program_stream.quantity)
    end

    scenario 'rules' do
      expect(page).to have_content('Age')
    end

    scenario 'enrollment' do
      expect(page).to have_content('e-mail')
    end

    scenario 'tracking' do
      expect(page).to have_content('e-mail')
    end

    scenario 'leave_program' do
      expect(page).to have_content('e-mail')
    end

    scenario 'copy link' do
      expect(page).to have_link(nil, href: new_program_stream_path(program_stream_id: program_stream.id, ngo_name: program_stream.ngo_name))
    end

    scenario 'edit link' do
      expect(page).to have_link(nil, href: edit_program_stream_path(program_stream))
    end
  end

  feature 'import custom form to program stream on create', js: true do
    before do
      visit program_streams_path
      page.click_link 'Add New Program'
    end

    xscenario 'import custom form to trackings' do
      fill_in 'program_stream_name', with: 'Program Name'
      sleep 1
      click_link 'Next'
      page.find(".rule-filter-container select option[value='gender']", visible: false).select_option
      expect(page).to have_content 'Gender'
      page.click_link 'Next'
      sleep 1
      page.find('li[data-type="date"]').click
      page.click_link 'Next'
      sleep 2
      within('#trackings') do
        fill_in 'Name', with: 'Tracking Name'
      end
      page.find('.custom-field-list').click
      sleep 1
      find('a.copy-form').click
      expect(page).to have_content('Name')
    end
  end

  feature 'import custom form to program stream on edit', js: true  do
    before do
      visit program_streams_path
      expect(page).to have_link(nil, href: edit_program_stream_path(program_stream))
      click_link(nil, href: edit_program_stream_path(program_stream))
    end

    xscenario 'import custom form to trackings' do
      fill_in 'program_stream_name', with: 'Program Name'
      sleep 1
      click_link 'Next'
      sleep 1
      page.click_link 'Next'
      sleep 1
      page.click_link 'Next'
      sleep 1
      page.find('.custom-field-list').click
      sleep 1
      find('a.copy-form').click
      expect(page).to have_content('Name')
      expect(page).to have_content('e-mail')
    end
  end

  feature 'search', js: true do
    before do
      visit program_streams_path
    end
    scenario 'has results' do
      fill_in 'program_stream_name', with: 'Program Stream Search'
      find('input.search').click
      sleep 1
      expect(page).to have_content(program_stream_search.name)
    end

    scenario 'no result found' do
      fill_in 'program_stream_name', with: 'No Result Found'
      find('input.search').click
      sleep 1
      expect(page).to have_content('No Result Found')
    end
  end
end
