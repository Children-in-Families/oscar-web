describe 'User' do
  let!(:admin){ create(:user, :admin, pin_number: '11223') }
  let!(:used_user){ create(:user) }
  let!(:user){ create(:user) }
  let!(:strategic_overviewer){ create(:user, :strategic_overviewer) }
  let!(:client){ create(:client, users: [used_user]) }

  let!(:custom_field){ create(:custom_field) }
  let!(:program_stream){ create(:program_stream) }

  feature 'List' do
    before do
      login_as(admin)
    end
    scenario 'pin_number must not be visible' do
      visit users_path
      expect(page).not_to have_content('11223')
    end
  end

  feature 'Show' do
    before do
      login_as(admin)
    end
    scenario 'pin_number must not be visible' do
      visit user_path(admin)
      expect(page).not_to have_content('11223')
    end
  end

  feature 'New' do
    before do
      login_as(admin)
    end
    scenario 'pin_number must not be visible' do
      visit new_user_path
      expect(page).not_to have_css('#user_pin_number')
    end
  end

  feature 'Create' do
    before do
      login_as(admin)
      visit new_user_path
      expect(page).to have_content('New User')
    end
    scenario 'valid' do
      fill_in 'First Name', with: 'Testing'
      fill_in 'Last Name', with: 'User'
      find('#user_gender option[value="female"]', visible: false).select_option
      fill_in 'Email', with: 'test@gmail.com'
      fill_in 'user[password]', with: '12345678'
      fill_in 'user[password_confirmation]', with: '12345678'
      find('#user_roles option[value="admin"]', visible: false).select_option
      find('input[value="Save"]').click
      expect(page).to have_content('Testing User')
      expect(page).to have_content('test@gmail.com')
      expect(page).to have_content('Female')
    end
    scenario 'invalid' do
      find('input[value="Save"]').click
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Edit' do
    before do
      login_as(admin)
    end
    scenario 'pin_number must not be visible' do
      visit edit_user_path(admin)
      expect(page).not_to have_css('#user_pin_number')
    end
  end

  feature 'List Managers' do
    before do
      login_as(admin)
    end

    let!(:manager_level_3){ create(:user, :manager) }
    let!(:manager_level_2){ create(:user, :manager) }
    let!(:manager_level_1){ create(:user, :manager) }
    let!(:other_manager){ create(:user, :manager) }
    let!(:case_worker){ create(:user, :case_worker, manager_id: manager_level_1.id) }

    xscenario 'New', js: true do
      visit new_user_path
      expect(page).to have_css('select#user_manager_id option', count: 5)
    end

    xscenario 'Edit', js: true do
      manager_level_1.update(manager_id: manager_level_2.id)
      visit edit_user_path(manager_level_2.reload)
      expect(page).to have_css('select#user_manager_id option', count: 3)
    end
  end

  feature 'Disable' do
    before do
      login_as(admin)
    end

    let!(:disable_user){ create(:user, email: 'aa@bb.com', disable: true, password: '12345678', password_confirmation: '12345678') }

    xscenario 'disable user from log in', js: true do
      visit users_path
      find("a[href='#{user_disable_path(used_user)}']").click
      expect(page).to have_css("i.fa.fa-lock", count: 2)
    end
    xscenario 'user unable to log in when disable', js: true do
      logout
      visit new_user_session_path
      fill_in 'Email', with: 'aa@bb.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(current_path).to eql('/users/sign_in')
    end
  end

  feature 'Delete' do
    before do
      login_as(admin)
      visit users_path
    end
    xscenario 'success', js: true do
      find("a[href='#{user_path(user)}'][data-method='delete']").click
      sleep 1
      expect(page).not_to have_content(user.name)
    end

    scenario 'does not succeed' do
      expect(page).to have_css("a[href='#{user_path(used_user)}'][data-method='delete'][class='btn btn-outline btn-danger btn-xs disabled']")
    end
  end

  feature 'Prompt User Warning' do
    context 'Admin' do
      before do
        login_as(admin)
      end

      scenario 'has seen the prompt' do
        visit program_streams_path
        expect(page).not_to have_css('#warning-program')

        visit domains_path
        expect(page).not_to have_css('#domain-warning')
      end

      scenario 'has not seen the prompt' do
        admin.update(domain_warning: false, program_warning: false)

        visit program_streams_path
        expect(page).to have_css('#warning-program')

        visit domains_path
        expect(page).to have_css('#domain-warning')
      end

      scenario 'access through button in side menu' do
        visit root_path
        find("a[id=manage]").click
        within '.navbar-default' do
          expect(page).to have_link('Program Streams', program_streams_path)
          expect(page).not_to have_css("a[data-target='#warning-program']")
          expect(page).to have_link('Domains', domains_path)
          expect(page).not_to have_css("a[data-target='#domain-warning']")
        end

        admin.update(program_warning: false, domain_warning: false)
        visit root_path
        find("a[id=manage]").click
        within '.navbar-default' do
          expect(page).not_to have_link('Program Streams', program_streams_path)
          expect(page).to have_css("a[data-target='#warning-program']")
          expect(page).not_to have_link('Domains', domains_path)
          expect(page).to have_css("a[data-target='#domain-warning']")
        end
      end
    end

    context 'User' do
      before do
        login_as(user)
      end

      scenario 'has seen the prompt' do
        visit program_streams_path
        expect(page).not_to have_css('#warning-program')

        visit domains_path
        expect(page).not_to have_css('#domain-warning')
      end

      scenario 'has not seen the prompt' do
        user.update(program_warning: false, domain_warning: false)

        visit program_streams_path
        expect(page).to have_css('#warning-program')

        visit domains_path
        expect(page).not_to have_css('#domain-warning')
      end

      scenario 'access through button in side menu' do
        visit root_path
        find("a[id=manage]").click
        within '.navbar-default' do
          expect(page).to have_link('Program Streams', program_streams_path)
          expect(page).not_to have_css("a[data-target='#warning-program']")
          expect(page).not_to have_link('Domains', domains_path)
          expect(page).not_to have_css("a[data-target='#domain-warning']")
        end

        user.update(program_warning: false, domain_warning: false)
        visit root_path
        find("a[id=manage]").click
        within '.navbar-default' do
          expect(page).not_to have_link('Program Streams', program_streams_path)
          expect(page).to have_css("a[data-target='#warning-program']")
          expect(page).not_to have_link('Domains', domains_path)
          expect(page).not_to have_css("a[data-target='#domain-warning']")
        end
      end
    end

    context 'Strategic Overviewer' do
      before do
        login_as(strategic_overviewer)
      end

      scenario 'has seen the prompt' do
        visit program_streams_path
        expect(page).not_to have_css('#warning-program')

        visit domains_path
        expect(page).not_to have_css('#domain-warning')
      end

      scenario 'has not seen the prompt' do
        strategic_overviewer.update(program_warning: false, domain_warning: false)

        visit program_streams_path
        expect(page).to have_css('#warning-program')

        visit domains_path
        expect(page).not_to have_css('#domain-warning')
      end

      scenario 'access through button in side menu' do
        visit root_path
        find("a[id=manage]").click
        within '.navbar-default' do
          expect(page).to have_link('Program Streams', program_streams_path)
          expect(page).not_to have_css("a[data-target='#warning-program']")
          expect(page).to have_link('Domains', domains_path)
          expect(page).not_to have_css("a[data-target='#domain-warning']")
        end

        strategic_overviewer.update(program_warning: false, domain_warning: false)
        visit root_path
        find("a[id=manage]").click
        within '.navbar-default' do
          expect(page).not_to have_link('Program Streams', program_streams_path)
          expect(page).to have_css("a[data-target='#warning-program']")
          expect(page).to have_link('Domains', domains_path)
          expect(page).not_to have_css("a[data-target='#domain-warning']")
        end
      end
    end
  end

  xfeature 'Permission' do
    before do
      visit user_path(user)
    end

    scenario 'success', js: true do
      find("button[data-target='#permissions']").click
      find('input.i-checks').iCheck('check')
    end
  end
end   
