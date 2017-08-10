feature 'program_stream' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:domain) { create(:domain) }
  let!(:program_stream) { create(:program_stream, ngo_name: Organization.current.full_name) }
  let!(:tracking) { create(:tracking, program_stream: program_stream) }
  let!(:domain_program_stream){ create(:domain_program_stream, domain: domain, program_stream: program_stream) }

  before do 
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
  end

  feature 'show' do
    before do 
      visit program_stream_path(program_stream)
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
      scenario 'valid' do
        fill_in 'program_stream_name', with: FFaker::Name.name
        sleep 1
        click_link 'Next'
        page.find(".rule-filter-container select option[value='gender']", visible: false).select_option
        expect(page).to have_content 'Gender'

        page.click_link 'Next'
        page.find('.icon-calendar').click
        page.click_link 'Next'
        sleep 1
        within('#trackings') do
          fill_in 'Name', with: FFaker::Name.name
        end
        page.find('.icon-text-input').click
        page.click_link 'Next'
        sleep 1
        page.find('.icon-text-area').click
        page.click_link 'Save'
        expect(page).to have_content('Program Stream has been successfully created.')
      end

      scenario 'invalid' do
        page.click_link 'Next'
        expect(page).to have_css '.error'
      end
    end

    context 'save draft' do
      scenario 'valid' do
        fill_in 'program_stream_name', with: FFaker::Name.name
        find('span', text: 'Save').click
        expect(page).to have_content('Incompleted')
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

    context 'full step' do
      scenario 'valid' do
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
      scenario 'valid' do
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
    before do 
      visit program_streams_path
    end

    scenario 'delete successfully' do
      find("a[href='#{program_stream_path(program_stream)}'][data-method='delete']").click
      expect(page).to have_content('Program Stream has been successfully deleted')
    end
  end

  feature 'Copy', js: true do
    before do
      visit program_streams_path
    end

    scenario 'valid' do
      click_link "All NGO's Program Streams"
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

      expect(page).to have_content('Program Stream has been successfully created.')
    end

    scenario 'invalid' do
      click_link "All NGO's Program Streams"
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
      click_link "All NGO's Program Streams"
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
end