describe 'Notification' do
  let!(:admin){ create(:user, roles: 'admin', referral_notification: true) }
  before do
    login_as(admin)
  end

  feature 'Unsaved Referral Notification', js: true do
    let!(:referral){ create(:referral, referred_to: 'app', referred_from: 'Demo') }
    before do
      visit dashboards_path
      find('.count-info').click
    end

    scenario 'bell notification' do
      expect(page).to have_link('You have 1 new referral client', href: referrals_notifications_path)
    end

    scenario 'list client referrals notification' do
      find_link('You have 1 new referral client').click
      expect(page).to have_link("#{referral.client_name} #{referral.slug}", href: new_client_path(referral_id: referral.id))
    end
  end

  feature 'Repeat Referral Notification', js: true do
    let!(:client){ create(:client)}
    let!(:referral){ create(:referral, client_id: client.id, slug: client.slug, referred_to: 'app', referred_from: 'Demo') }
    before do
      visit dashboards_path
      find('.count-info').click
    end

    scenario 'bell notification' do
      expect(page).to have_link('You have 1 repeat referral client', href: repeat_referrals_notifications_path)
    end

    scenario 'list client referrals notification' do
      find_link('You have 1 repeat referral client').click
      expect(page).to have_link("#{referral.client_name} #{referral.slug}", href: edit_client_path(client, referral_id: referral.id))
    end
  end
end
