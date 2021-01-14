describe 'FamilyReferral' do
    # let!(:user) { create(:user, :admin) }
    # let!(:family) { create(:family, :active) }
    # let!(:family_1) { create(:family, :active) }
    # let!(:family_referral) { create(:family_referral, family: family, slug: family.slug) }
    # let!(:family_referral_1) { create(:family_referral, family: family_1, saved: true, slug: family_1.slug) }
  
    # before do
    #   login_as(user)
    # end
  
    # feature 'Create' do
    #   feature 'can refer to other NGO' do
    #     before do
    #       visit family_path(family)
    #       find('#add-referral-btn').click
    #       find('#mho').click
    #     end
  
    #     scenario 'valid' do
    #       find("select#referral_referred_to option[value='external referral']", visible: false).select_option
    #       expect(page).to have_content('The NGO that you are attempting to refer your family to is not currently using OSCaR.')
    #       fill_in 'family_referral_referral_reason', with: FFaker::Lorem.paragraph
    #       find('#family_referral_consent_form', visible: false).set('spec/supports/file.docx')
    #       click_button 'Save'
    #       sleep 1
    #       expect(page).to have_content(family.name)
    #     end
  
    #     scenario 'invalid' do
    #       find('.btn-save').click
    #       expect(page).to have_content("can't be blank")
    #     end
    #   end
  
    #   scenario 'already referred', js: true do
    #     visit family_path(family)
    #     find('#add-referral-btn').click
    #     find('#mho').click
    #     expect(page).to have_content('You have already referred this family, please wait for the response.')
    #   end
  
    #   scenario 'already existed', js: true do
    #     Organization.switch_to 'mtp'
    #     create(:family, slug: family.slug)
    #     referral_mho = FamilyReferral.find_by(slug: family.slug)
    #     referral_mho.update(saved: true)
    #     Organization.switch_to 'app'
    #     visit family_path(family)
    #     find('#add-referral-btn').click
    #     find('#mtp').click
    #     expect(page).to have_content('The family you want to refer already existed in the target NGO.')
    #   end
    # end
  
    # feature 'List' do
    #   before do
    #     visit family_path(family)
    #   end
  
    #   scenario 'list referred to external organization' do
    #     find('#add-referral-btn').click
    #     click_link 'Referred to External Organisation'
    #     expect(page).to have_content('Referred To')
    #   end
  
    #   scenario 'list referred from external organization' do
    #     find('#add-referral-btn').click
    #     click_link 'Referred from External Organisation'
    #     expect(page).to have_content('Reffered From')
    #   end
    # end
  
    # feature 'Update' do
    #   scenario 'can edit referral', js: true do
    #     visit edit_family_family_referral_path(family, family_referral)
    #     fill_in 'family_referral_referral_phone', with: '012345678'
    #     find('#family_referral_consent_form', visible: false).set('spec/supports/file.docx')
    #     click_button 'Save'
    #     expect(page).to have_content('012345678')
    #   end
  
    #   scenario 'cannot edit referral', js: true do
    #     visit edit_family_family_referral_path(family_1, family_referral_1)
    #     expect(page).to have_content('You are not authorized to access this page.')
    #   end
    # end
  
    # feature 'show' do
    #   before do
    #     visit family_family_referral_path(family, family_referral)
    #   end
  
    #   scenario 'Created by .. on ..' do
    #     user = family_referral.name_of_referee
    #     date = date_format(family_referral.created_at)
    #     expect(page).to have_content("Created by #{user} on #{date}")
    #   end
  
    #   scenario 'Date of referral' do
    #     expect(page).to have_content(date_format(family_referral.date_of_referral))
    #   end
  
    #   scenario 'Name of Family' do
    #     expect(page).to have_content(family_referral.name_of_family)
    #   end
  
    #   scenario 'Referred From' do
    #     expect(page).to have_content(family_referral.referred_from_ngo)
    #   end
  
    #   scenario 'Referred To' do
    #     expect(page).to have_content(family_referral.referred_to_ngo)
    #   end
  
    #   scenario 'Case Worker' do
    #     expect(page).to have_content(family_referral.name_of_referee)
    #   end
  
    #   scenario 'Referee Phone' do
    #     expect(page).to have_content(family_referral.referral_phone)
    #   end
  
    #   scenario 'Referral Reason' do
    #     expect(page).to have_content(family_referral.referral_reason)
    #   end
    # end
  end
  