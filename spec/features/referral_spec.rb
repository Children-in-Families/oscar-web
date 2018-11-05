describe 'Referral' do
  let!(:user) { create(:user, :admin) }
  let!(:client) { create(:client, :accepted) }
  let!(:client_1) { create(:client, :accepted) }
  let!(:client_2) { create(:client, :accepted) }
  let!(:referral) { create(:referral, client: client, slug: client.slug) }
  let!(:referral_1) { create(:referral, client: client_1, saved: true, slug: client_1.slug) }

  before do
    login_as(user)
  end

  feature 'Create' do
    feature 'can refer to other NGO' do
      before do
        visit client_path(client_2)
        find('#add-referral-btn').click
        find('#mtp').click
      end

      scenario 'valid' do
        find("select#referral_referred_to option[value='external referral']", visible: false).select_option
        expect(page).to have_content('The NGO that you are attempting to refer your client to is not currently using OSCaR.')
        fill_in 'referral_referral_reason', with: FFaker::Lorem.paragraph
        find('#referral_consent_form', visible: false).set('spec/supports/file.docx')
        click_button 'Save'
        sleep 1
        expect(page).to have_content(client_2.en_and_local_name)
      end

      scenario 'invalid' do
        find('.btn-save').click
        expect(page).to have_content("can't be blank")
      end
    end

    scenario 'already referred', js: true do
      visit client_path(client)
      find('#add-referral-btn').click
      find('#mtp').click
      expect(page).to have_content('You have already referred this client, please wait for the response.')
    end

    scenario 'already existed', js: true do
      Organization.switch_to 'mtp'
      create(:client, slug: client.slug)
      referral_mtp = Referral.find_by(slug: client.slug)
      referral_mtp.update(saved: true)
      Organization.switch_to 'app'
      visit client_path(client)
      find('#add-referral-btn').click
      find('#mtp').click
      expect(page).to have_content('The client you want to refer already existed in the target NGO.')
    end

    scenario 'referral was rejected by org', js: true do
      Organization.switch_to 'mtp'
      create(:client, slug: client_1.slug)
      create(:exit_ngo, client: client_1)
      referral_mtp = Referral.find_by(slug: client_1.slug)
      referral_mtp.update(saved: true)
      Organization.switch_to 'app'
      visit client_path(client_1)
      find('#add-referral-btn').click
      find('#mtp').click
      expect(page).to have_content('I have discussed the situation with them.')
    end

  end

  feature 'List' do
    before do
      visit client_path(client)
    end

    scenario 'list referred to external organization' do
      find('#add-referral-btn').click
      click_link 'Referred to External Organisation'
      expect(page).to have_content('Referred To')
    end

    scenario 'list referred from external organization' do
      find('#add-referral-btn').click
      click_link 'Referred from External Organisation'
      expect(page).to have_content('Reffered From')
    end
  end

  feature 'Update' do
    scenario 'can edit referral', js: true do
      visit edit_client_referral_path(client, referral)
      fill_in 'referral_referral_phone', with: '012345678'
      find('#referral_consent_form', visible: false).set('spec/supports/file.docx')
      click_button 'Save'
      expect(page).to have_content('012345678')
    end

    scenario 'cannot edit referral', js: true do
      visit edit_client_referral_path(client_1, referral_1)
      expect(page).to have_content('You are not authorized to access this page.')
    end
  end

  feature 'show' do
    before do
      visit client_referral_path(client, referral)
    end

    scenario 'Created by .. on ..' do
      user = referral.name_of_referee
      date = date_format(referral.created_at)
      expect(page).to have_content("Created by #{user} on #{date}")
    end

    scenario 'Date of referral' do
      expect(page).to have_content(date_format(referral.date_of_referral))
    end

    scenario 'Client Name' do
      expect(page).to have_content(referral.client_name)
    end

    scenario 'Client ID' do
      expect(page).to have_content(referral.slug)
    end

    scenario 'Referred From' do
      expect(page).to have_content(referral.referred_from_ngo)
    end

    scenario 'Referred To' do
      expect(page).to have_content(referral.referred_to_ngo)
    end

    scenario 'Case Worker' do
      expect(page).to have_content(referral.name_of_referee)
    end

    scenario 'Referee Phone' do
      expect(page).to have_content(referral.referral_phone)
    end

    scenario 'Referral Reason' do
      expect(page).to have_content(referral.referral_reason)
    end
  end
end
