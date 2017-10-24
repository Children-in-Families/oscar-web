describe 'User' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:used_user){ create(:user) }
  let!(:user){ create(:user) }

  let!(:location){ create(:location, name: 'ផ្សេងៗ Other') }
  let!(:progress_note){ create(:progress_note, user: used_user, location: location) }

  let!(:custom_field){ create(:custom_field) }
  let!(:program_stream){ create(:program_stream) }

  before do
    login_as(admin)
  end

  feature 'Disable' do
    let!(:disable_user){ create(:user, email: 'aa@bb.com', disable: true, password: '12345678', password_confirmation: '12345678') }

    scenario 'disable user from log in', js: true do
      visit users_path
      find("a[href='#{user_disable_path(used_user)}']").click
      expect(page).to have_css("i.fa.fa-lock", count: 2)
    end
    scenario 'user unable to log in when disable', js: true do
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
      visit users_path
    end
    scenario 'success', js: true do
      find("a[href='#{user_path(user)}'][data-method='delete']").click
      sleep 1
      expect(page).not_to have_content(user.name)
    end

    scenario 'does not succeed' do
      expect(page).to have_css("a[href='#{user_path(used_user)}'][data-method='delete'][class='btn btn-outline btn-danger btn-xs disabled']")
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
