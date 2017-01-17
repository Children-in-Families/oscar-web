describe 'User' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:used_user){ create(:user) }
  let!(:user){ create(:user) }

  let!(:location){ create(:location, name: 'ផ្សេងៗ Other') }
  let!(:progress_note){ create(:progress_note, user: used_user, location: location) }

  before do
    login_as(admin)
  end

  feature 'Disable' do
    let!(:disable_user){ create(:user, email: 'aa@bb.com', disable: true, password: '12345678', password_confirmation: '12345678') }

    scenario 'disable user from log in', js: true do
      visit users_path
      find("a[href='#{user_disable_path(used_user)}']").click
      expect(page).to have_content(I18n.t('users.disable.successfully_disable'))
    end
    scenario 'user unable to log in when disable', js: true do
      logout
      visit new_user_session_path
      fill_in 'Email', with: 'aa@bb.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Your account is not activated yet'
    end
  end

  feature 'Delete' do
    before do
      visit users_path
    end
    scenario 'success', js: true do
      find("a[href='#{user_path(user)}'][data-method='delete']").click
      sleep 1
      expect(page).to have_content(I18n.t('users.destroy.successfully_deleted'))
    end

    scenario 'does not succeed' do
      expect(page).to have_css("a[href='#{user_path(used_user)}'][data-method='delete'][class='btn btn-outline btn-danger btn-xs disabled']")
    end
  end

end
