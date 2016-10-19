describe 'User' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:used_user){ create(:user) }
  let!(:user){ create(:user) }
  let!(:location){ create(:location, name: 'ផ្សេងៗ Other') }
  let!(:progress_note){ create(:progress_note, user: used_user, location: location) }

  before do
    login_as(admin)
  end

  feature 'Delete' do
    before do
      visit users_path
    end
    scenario 'success' do
      find("a[href='#{user_path(user)}'][data-method='delete']").click
      expect(page).to have_content(I18n.t('users.destroy.successfully_deleted'))
    end

    scenario 'does not succeed' do
      expect(page).not_to have_css("a[href='#{user_path(used_user)}'][data-method='delete']")
    end
  end
end
