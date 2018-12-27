describe 'Domain' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:domain_group){ create(:domain_group) }
  let!(:domain){ create(:domain, name: 'Domain ABC') }
  let!(:other_domain){ create(:domain, custom_domain: true) }
  let!(:custom_domain_1){ create(:domain, name: 'Custom Domain Name', custom_domain: true) }
  let!(:task){ create(:task, domain: other_domain) }
  before do
    login_as(admin)
  end

  feature 'List' do
    before do
      visit domains_path
    end

    feature 'validate_organization' do
      feature 'current instance is not Demo' do
        scenario 'stays on the same page' do
          expect(domains_path.split('?').first).to eq(current_path)
        end
      end

      xfeature 'current instance is Demo'
    end

    scenario 'name' do
      expect(page).to have_content(domain.name)
    end

    context 'new link', js: true do
      scenario 'default csi tab' do
        expect(page).not_to have_link('Add New Domain', href: new_domain_path, visible: true)
      end

      scenario 'custom csi tab' do
        find('a[href="#custom-csi-tools"]').trigger('click')
        expect(page).to have_link('Add New Domain', href: new_domain_path, visible: true)
      end
    end

    context 'edit link', js: true do
      scenario 'default csi tab' do
        expect(page).not_to have_link(nil, href: edit_domain_path(domain))
      end

      scenario 'custom csi tab' do
        find('a[href="#custom-csi-tools"]').trigger('click')

        expect(page).to have_link(nil, href: edit_domain_path(custom_domain_1))
      end
    end

    scenario 'copy link' do
      expect(page).to have_link(nil, href: new_domain_path(domain_id: domain.id, copy: true))
    end

    context 'delete link', js: true do
      scenario 'default csi tab' do
        expect(page).not_to have_css("a[href='#{domain_path(domain)}'][data-method='delete']")
      end

      scenario 'custom csi tab' do
        find('a[href="#custom-csi-tools"]').trigger('click')

        expect(page).to have_css("a[href='#{domain_path(custom_domain_1)}'][data-method='delete']")
      end
    end
  end

  feature 'Create', js: true do
    let!(:another_domain) { create(:domain, name: 'Another Domain', custom_domain: true) }
    before do
      visit new_domain_path
    end
    scenario 'valid' do
      fill_in 'Name', with: 'Domain Name 1'
      fill_in 'Identity', with: 'Domain Identity'
      fill_in 'domain_score_1_definition', with: 'Score 1 Description'
      click_button 'Save'
      sleep 1
      find('a[href="#custom-csi-tools"]').trigger('click')
      sleep 1
      expect(page).to have_content('Domain Name 1')
      expect(page).to have_content('Domain Identity')
    end
    scenario 'invalid' do
      fill_in 'Name', with: 'Another Domain'
      fill_in 'Identity', with: 'Domain Identity'
      click_button 'Save'
      expect(page).to have_content('has already been taken')
    end
  end

  feature 'Copy' do
    before do
      visit domains_path
    end

    scenario 'Valid', js: true do
      first("a[href='#{new_domain_path(domain_id: domain.id, copy: true)}']").click
      sleep 1
      expect(find_field('domain_name').value).to eq 'Domain ABC'
    end
  end

  feature 'Edit', js: true do
    context 'default csi' do
      before { visit edit_domain_path(domain) }

      it 'not allowed' do
        expect(page.status_code).to eq(404)
      end
    end

    context 'custom csi' do
      before { visit edit_domain_path(custom_domain_1) }

      scenario 'valid', js: true do
        fill_in 'Name', with: 'Updated Domain Name'
        click_button 'Save'
        sleep 1
        find('a[href="#custom-csi-tools"]').trigger('click')
        expect(page).to have_content('Updated Domain Name')
      end
      scenario 'invalid' do
        fill_in 'Name', with: ''
        click_button 'Save'
        expect(page).to have_content("can't be blank")
      end
    end
  end

  feature 'Delete', js: true do
    before do
      visit domains_path
    end
    scenario 'success' do
      find('a[href="#custom-csi-tools"]').trigger('click')
      sleep 1
      first("a[href='#{domain_path(custom_domain_1)}'][data-method='delete']").trigger('click')
      sleep 1
      find('a[href="#custom-csi-tools"]').trigger('click')
      sleep 1
      expect(page).not_to have_content(custom_domain_1.name)
    end
    scenario 'disable delete' do
      find('a[href="#custom-csi-tools"]').trigger('click')
      sleep 1
      expect(page).to have_css("a[href='#{domain_path(other_domain)}'][data-method='delete'][class='btn btn-outline btn-danger margin-left disabled']")
    end
  end
end
