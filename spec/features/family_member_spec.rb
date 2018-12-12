describe 'FamilyMember' do
  feature 'index' do
    let!(:admin){ create(:user, :admin) }
    let!(:family) { create(:family, :emergency) }
    let!(:family_member) { create(:family_member, family: family) }

    before do
      login_as(admin)
      visit family_path(family)
    end

    scenario 'family members fields' do
      expect(page).to have_content(family_member.adult_name)
      expect(page).to have_content(date_format(family_member.date_of_birth))
      expect(page).to have_content(family_member.occupation)
      expect(page).to have_content(family_member.relation)
    end
  end

  feature 'create' do
    let!(:admin){ create(:user, :admin) }
    let!(:family) { create(:family, :emergency) }

    before do
      login_as(admin)
      visit edit_family_path(family)
    end

    scenario 'successful', js:true do
      find('.add_new_member').click
      fill_in 'Name of Adult Member', with: 'Allen'
      fill_in 'Occupation', with: 'Developer'
      find('input.form-btn').click
      expect(page).to have_content('Allen')
      expect(page).to have_content('Developer')
    end
  end

  feature 'update' do
    let!(:admin){ create(:user, :admin) }
    let!(:family) { create(:family, :emergency) }
    let!(:family_member) { create(:family_member, family: family) }

    before do
      login_as(admin)
      visit edit_family_path(family)
    end

    scenario 'successful', js:true do
      fill_in 'Name of Adult Member', with: 'Allen'
      fill_in 'Occupation', with: 'Developer'
      find('input.form-btn').click
      expect(page).to have_content('Allen')
      expect(page).to have_content('Developer')
    end
  end

  feature 'destroy' do
    let!(:admin){ create(:user, :admin) }
    let!(:family) { create(:family, :emergency) }
    let!(:family_member) { create(:family_member, family: family) }

    before do
      login_as(admin)
      visit edit_family_path(family)
    end

    scenario 'successful', js:true do
      find('.remove_member').click
      find('input.form-btn').click
      expect(page).not_to have_content(family_member.adult_name)
      expect(page).not_to have_content(family_member.date_of_birth)
      expect(page).not_to have_content(family_member.occupation)
      expect(page).not_to have_content(family_member.relation)
    end
  end
end
