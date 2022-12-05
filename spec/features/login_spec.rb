describe 'Login' do
  let!(:user){ create(:user) }
  feature 'Login', js: true do
    before do
      logout(:user)
      visit '/users/sign_in'
      expect(page). to have_content('Email', 'Password')
    end
    scenario 'valid' do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      sleep 1
      find('.btn-login').click
      expect(page).to have_content('Signed in successfully.')
      expect(page).to have_content(user.first_name)
    end
    scenario 'invalid' do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: '1234'
      find('.btn-login').click
      expect(page).to have_content('Invalid email or password.')
    end
    scenario 'validation' do
      find('.btn-login').click
      expect(page).to have_content('Invalid email or password.')
    end
  end
end