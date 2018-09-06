describe 'Family' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:province){create(:province,name:"Phnom Penh")}
  let!(:district){ create(:district, name: 'Toul Kork', province_id: province.id) }

  let!(:foster_family){ create(:family, :foster, name: 'A') }
  let!(:case_worker_a){ create(:user, first_name: 'CW A') }
  let!(:case_worker_b){ create(:user, first_name: 'CW B') }
  let!(:case_worker_c){ create(:user, first_name: 'CW C') }
  let!(:client_a){ create(:client, :accepted, users: [case_worker_a, case_worker_c]) }
  let!(:client_b){ create(:client, :accepted, users: [case_worker_b]) }
  let!(:case_a){ create(:case, :foster, client: client_a, family: foster_family) }
  let!(:case_b){ create(:case, :foster, client: client_b, family: foster_family) }

  let!(:client){ create(:client, :accepted) }
  let!(:village_1){ create(:village, name_en: 'Wat Neak Kwan') }
  let!(:commune_1){ create(:commune, name_en: 'Beoung Kak 2') }
  let!(:family){ create(:family, :emergency, name: 'EC Family', province_id: province.id, district_id: district.id, commune_id: commune_1.id, village_id: village_1.id, children: [client.id]) }
  let!(:other_family){ create(:family, name: 'Unknown', dependable_income: true) }
  let!(:case){ create(:case, family: other_family) }
  let!(:another_client){ create(:client, :accepted) }
  let!(:other_client){ create(:client) }

  before do
    login_as(admin)
  end
  feature 'List' do
    before do
      visit families_path
    end

    xscenario 'case workers', js: true, skip: '=== consider changing retrieving data logic ===' do
      first('td.case_workers a[href="#"]').click
      sleep 1
      expect(page).to have_content(case_worker_a.name)
      expect(page).to have_content(case_worker_b.name)
      expect(page).to have_content(case_worker_c.name)
    end

    scenario 'name' do
      expect(page).to have_content(family.name)
    end

    scenario 'edit link' do
      expect(page).to have_link(nil, edit_family_path(family))
    end

    scenario 'delete link' do
      expect(page).to have_css("a[href='#{family_path(family)}'][data-method='delete']")
    end

    scenario 'show link' do
      expect(page).to have_link(nil, family_path(family))
    end

    scenario 'new link' do
      expect(page).to have_link('Add New Family', new_family_path)
    end
  end

  feature 'Create', js: true do
    before do
      visit new_family_path
    end
    scenario 'valid' do
      fill_in 'Name', with: 'Family Name'
      find(".family_province select option[value='#{province.id}']", visible: false).select_option
      sleep 1
      # find(".family_district select option[value='#{district.id}']", visible: false).select_option
      fill_in 'Caregiver Information', with: 'Caregiver info'
      find(".family_children select option[value='#{another_client.id}']", visible: false).select_option
      find(".family_family_type select option[value='Short Term / Emergency Foster Care']", visible: false).select_option
      find(".family_status select option[value='Active']", visible: false).select_option
      click_button 'Save'
      sleep 1
      expect(page).to have_content('Family Name')
      # expect(page).to have_content("#{district.name}, #{province.name}")
      expect(page).to have_content(province.name)
      expect(page).to have_content('Caregiver info')
      expect(page).to have_content('Family has been successfully created')
      expect(page).to have_content(another_client.given_name)
      expect(page).not_to have_content(other_client.given_name)
    end

    scenario 'client must belong to only a family' do
      find('.family_children').click
      expect(page).not_to have_content(client.given_name)
      expect(page).to have_select('Clients', options: [another_client.en_and_local_name, other_client.en_and_local_name])
    end

    scenario 'invalid' do
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Update', js: true do
    let!(:pirunseng){ create(:client, :accepted, given_name: 'Pirun', family_name: 'Seng') }
    # let!(:ec_family){ create(:family, :emergency, name: 'Emergency Family') }
    let!(:non_case_family){ create(:family, family_type: ['Other', 'Birth Family (Both Parents)'].sample) }
    let!(:non_case){ create(:case, case_type: 'Referred', client: pirunseng, family: non_case_family) }
    # let!(:ec_case){ create(:case, :emergency, client: pirunseng, family: ec_family) }
    let!(:another_family){ create(:family, :emergency) }
    let!(:another_client){ create(:client, :accepted) }

    feature 'valid' do
      before do
        visit edit_family_path(non_case_family)
      end
      scenario 'name' do
        fill_in 'Name', with: 'Family Name'
        click_button 'Save'
        sleep 1
        expect(page).to have_content('Family Name')
      end
    end

    feature 'remove clients from' do
      scenario 'birth or inactive family is valid' do
        visit edit_family_path(non_case_family)
        unselect('Pirun Seng', from: 'Clients', visible: false)
        click_button 'Save'
        sleep 1
        expect(page).to have_content('Family has been successfully updated')
      end
    end

    scenario 'client must belong to only a family' do
      visit edit_family_path(another_family)
      find('.family_children').click
      expect(page).not_to have_select('Clients', options: [pirunseng.en_and_local_name])
    end
  end

  feature 'Delete', js: true do
    before do
      visit families_path
    end
    scenario 'success' do
      find("a[href='#{family_path(family)}'][data-method='delete']").click
      sleep 1
      expect(page).not_to have_content(family.name)
    end
    scenario 'unsuccess' do
      expect(page).to have_css("a[href='#{family_path(other_family)}'][data-method='delete'][class='btn btn-outline btn-danger btn-xs disabled']")
    end
  end

  feature 'Show' do
    before do
      visit family_path(family)
    end
    scenario 'success' do
      expect(page).to have_content(family.name)
    end
    scenario 'link to edit' do
      expect(page).to have_link(nil, href: edit_family_path(family))
    end
    scenario 'link to delete' do
      expect(page).to have_css("a[href='#{family_path(family)}'][data-method='delete']")
    end
    scenario 'disable delete' do
      visit family_path(other_family)
      expect(page).to have_css("a[href='#{family_path(other_family)}'][data-method='delete'][class='btn btn-outline btn-danger btn-md disabled']")
    end
  end

  feature 'Filter', js: true do
    before do
      visit families_path
      find('button.family-search').click
    end
    scenario 'filter by family type' do
      page.find("#family-search-form select#family_grid_family_type option[value='Short Term / Emergency Foster Care']", visible: false).select_option
      click_button 'Search'
      expect(page).to have_content(family.name)
      expect(page).not_to have_content(other_family)
    end

    scenario 'filter by family like name' do
      fill_in('family_grid_name',with: 'Family')
      click_button 'Search'
      expect(page).to have_content(family.name)
      expect(page).not_to have_content(other_family)
    end

    scenario 'filter by family id' do
      fill_in('family_grid_id',with: family.id)
      click_button 'Search'
      expect(page).to have_content(family.name)
      expect(page).not_to have_content(other_family)
    end

    scenario 'filter by family province' do
      province_id = Province.find_by(name: 'Phnom Penh').id
      page.find("#family-search-form select#family_grid_province_id option[value='#{province_id}']", visible: false).select_option
      sleep 1
      click_button 'Search'
      expect(page).to have_content(family.name)
      expect(page).not_to have_content(other_family.name)
    end

    scenario 'filter by family district' do
      district_id = District.find_by(name: 'Toul Kork').id
      page.find("#family-search-form select#family_grid_district_id option[value='#{district_id}']", visible: false).select_option
      sleep 1
      click_button 'Search'
      expect(page).to have_content(family.name)
      expect(page).not_to have_content(other_family.name)
    end

    scenario 'filter by family commune' do
      commune_id = Commune.find_by(name_en: 'Beoung Kak 2').id
      page.find("#family-search-form select#family_grid_commune_id option[value='#{commune_id}']", visible: false).select_option
      sleep 1
      click_button 'Search'
      expect(page).to have_content(family.name)
      expect(page).not_to have_content(other_family.name)
    end

    scenario 'filter by family village' do
      village_id = Village.find_by(name_en: 'Wat Neak Kwan').id
      page.find("#family-search-form select#family_grid_village_id option[value='#{village_id}']", visible: false).select_option
      sleep 1
      click_button 'Search'
      expect(page).to have_content(family.name)
      expect(page).not_to have_content(other_family.name)
    end

    scenario 'filter by family dependable income' do
      page.find("#family-search-form select#family_grid_dependable_income option[value='NO']", visible: false).select_option
      sleep 1
      click_button 'Search'
      expect(page).to have_content(family.name)
      expect(page).not_to have_content(other_family.name)
    end
  end
end
