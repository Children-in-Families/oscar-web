describe 'Partner' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:ngo){ create(:organization_type, name: 'NGO')}
  let!(:partner){ create(:partner, organization_type: ngo, name: 'Jonh') }
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

  xfeature 'Create' do
    before do
      visit new_partner_path
    end
    scenario 'valid', js: true do
      fill_in 'Name', with: 'Partner Name'
      fill_in 'Email', with: 'test@example.com'
      click_button 'Save'
      sleep 1
      expect(page).to have_content('Partner Name')
      expect(page).to have_content('test@example.com')
    end
    scenario 'invalid' do
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end
  xfeature 'Edit', js: true do
    before do
      visit edit_partner_path(partner)
    end
    scenario 'valid' do
      fill_in 'Name', with: 'Updated Partner Name'
      fill_in 'Email', with: 'test@example1.com'
      click_button 'Save'
      sleep 1
      expect(page).to have_content('Updated Partner Name')
      expect(page).to have_content('test@example1.com')
    end
    scenario 'invalid'
  end
  feature 'Delete' do
    before do
      visit partners_path
    end
    scenario 'success', js: true do
      find("a[href='#{partner_path(partner)}'][data-method='delete']").click
      sleep 1
      expect(page).not_to have_content(partner.name)
    end
    scenario 'unsuccess' do
      expect(page).to have_css("a[href='#{partner_path(other_partner)}'][class='btn btn-outline btn-danger btn-xs disabled']")
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
      expect(page).to have_css("a[href='#{partner_path(other_partner)}'][data-method='delete'][class='btn btn-outline btn-danger btn-md disabled']")
    end
  end

  feature 'Filter',js: true do
    before do
      visit partners_path
      find(".partner-search").click
    end

    scenario 'filter by organisation type' do
      page.find("#partner-search-form select#partner_grid_organization_type option[value='#{ngo.id}']", visible: false).select_option
      click_button 'Search'
      expect(page).to have_content(partner.name)
    end

  end
end
