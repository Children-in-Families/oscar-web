describe 'Partner' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:partner){ create(:partner) }
  let!(:other_partner){ create(:partner) }
  let!(:case){ create(:case, partner: other_partner) }
  before do
    login_as(admin)
  end
  feature 'List' do
    before do
      visit partners_path
    end
    scenario 'name' do
      expect(page).to have_content(partner.name)
      expect(page).to have_content(other_partner.name)
    end
    scenario 'new link' do
      expect(page).to have_link('Add New Partner', href: new_partner_path)
    end
    scenario 'edit link' do
      expect(page).to have_link(nil, href: edit_partner_path(partner))
    end
    scenario 'delete link' do
      expect(page).to have_css("a[href='#{partner_path(partner)}'][data-method='delete']")
    end
    scenario 'show link' do
      expect(page).to have_link(partner.name, href: partner_path(partner))
    end
  end
  feature 'Create' do
    before do
      visit new_partner_path
    end
    scenario 'valid' do
      fill_in 'Name', with: FFaker::Name.name
      fill_in 'Email', with: FFaker::Internet.email
      click_button 'Save'
      expect(page).to have_content('Partner has been successfully created')
    end
    xscenario 'invalid' do
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end
  feature 'Edit' do
    before do
      visit edit_partner_path(partner)
    end
    scenario 'valid' do
      fill_in 'Name', with: FFaker::Name.name
      fill_in 'Email', with: FFaker::Internet.email
      click_button 'Save'
      expect(page).to have_content('Partner has been successfully updated')
    end
    xscenario 'invalid'
  end
  feature 'Delete' do
    before do
      visit partners_path
    end
    scenario 'success' do
      find("a[href='#{partner_path(partner)}'][data-method='delete']").click
      expect(page).to have_content('Partner has been successfully deleted')
    end
    scenario 'unsuccess' do
      expect(page).not_to have_css("a[href='#{partner_path(other_partner)}'][data-method='delete']")
    end
  end

  feature 'Show' do
    before do
      visit partner_path(partner)
    end
    scenario 'success' do
      expect(page).to have_content(partner.name)
    end
    scenario 'link to edit' do
      expect(page).to have_link(nil, href: edit_partner_path(partner))
    end
    scenario 'link to delete' do
      expect(page).to have_css("a[href='#{partner_path(partner)}'][data-method='delete']")
    end
    scenario 'disable delete link' do
      visit partner_path(other_partner)
      expect(page).not_to have_css("a[href='#{partner_path(other_partner)}'][data-method='delete']")
    end
  end
end
