feature 'program_stream' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:domain) { create(:domain) }
  let!(:program_stream) { create(:program_stream) }
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

    scenario 'rules', js: true do
      page.click_link('Rules')
      expect(page).to have_content('Age')
    end

    scenario 'enrollment', js: true do
      page.click_link('Enrollment')
      expect(page).to have_content('e-mail')
    end

    scenario 'tracking', js: true do
      page.click_link('Tracking')
      expect(page).to have_content('e-mail')
    end

    scenario 'leave_program', js: true do
      page.click_link('Exit Program')
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
      visit new_program_stream_path
    end

    scenario 'valid' do
      fill_in 'Name', with: FFaker::Name.name
      page.find(".rule-filter-container select option[value='gender']", visible: false).select_option
      expect(page).to have_content 'Gender'
      page.click_link 'Next'
      page.find('.icon-calendar').click
      page.click_link 'Next'
      sleep 1
      page.find('.icon-text-input').click
      page.click_link 'Next'
      sleep 1
      page.find('.icon-text-area').click
      page.click_link 'Save'
      expect(page).to have_content('Program Stream has been successfully created.')
    end

    scenario 'invalid' do
      fill_in 'Name', with: FFaker::Name.name
      page.click_link 'Next'
      element = page.find('dl.rules-group-container')
      expect(element).to have_css '.has-error'
    end
  end
end