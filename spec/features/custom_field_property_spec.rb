feature 'custom_field_property' do
  let!(:admin){ create(:user, :admin) }
  let!(:user_1){ create(:user, :case_worker, first_name: 'John', last_name: 'Doe') }

  let!(:user){ create(:user, :case_worker) }
  let!(:client){ create(:client, :accepted) }
  let!(:family){ create(:family) }
  let!(:partner){ create(:partner) }

  let!(:custom_field){ create(:custom_field, entity_type: 'Client') }
  let!(:custom_field_family){ create(:custom_field, entity_type: 'Family') }
  let!(:custom_field_partner){ create(:custom_field, entity_type: 'Partner') }
  let!(:custom_field_user){ create(:custom_field, entity_type: 'User') }

  let!(:custom_field_property){ create(:custom_field_property, custom_formable_type: 'Client', custom_field: custom_field, custom_formable_id: client.id, user_id: user_1.id) }
  let!(:custom_field_property_of_family){ create(:custom_field_property, custom_formable_type: 'Family', custom_field: custom_field_family, custom_formable_id: family.id, user_id: user_1.id) }
  let!(:custom_field_property_of_partner){ create(:custom_field_property, custom_formable_type: 'Partner', custom_field: custom_field_partner, custom_formable_id: partner.id, user_id: user_1.id) }
  let!(:custom_field_property_of_user){ create(:custom_field_property, custom_formable_type: 'User', custom_field: custom_field_user, custom_formable_id: user.id, user_id: user_1.id) }

  feature 'Client' do
    before do
      login_as(admin)
      visit client_custom_field_properties_path(client, custom_field_id: custom_field.id)
    end

    feature 'List' do
      scenario 'Form title' do
        expect(page).to have_content(custom_field.form_title)
      end

      scenario 'Caseworker name' do
        expect(page).to have_content('John Doe')
      end
    end

    feature 'Create' do
      scenario 'valid' do
        click_link 'Add New'
        find('input[type="text"]').set('Jake')
        click_button 'Save'
        expect(page).to have_content('Jake')
        within("#custom_field_property_#{CustomFieldProperty.last.id}") do
          find('h5', text: admin.name)
        end
      end
    end

    feature 'Edit' do
      scenario 'valid' do
        within("#custom_field_property_#{custom_field_property.id}") do
          click_link(nil, href: edit_polymorphic_path([client, custom_field_property], custom_field_id: custom_field.id))
        end

        click_button 'Save'

        expect(page).to have_content(custom_field.form_title)
        expect(page).to have_content('John Doe')
      end
    end

    feature 'Delete' do
      scenario 'successful' do
        find("a[data-method='delete'][href='#{polymorphic_path([client, custom_field_property], custom_field_id: custom_field.id)}']").click

        expect(page).to have_content(custom_field.form_title)
        expect(page).not_to have_content('John Doe')
      end
    end
  end

  feature 'Family' do
    before do
      login_as(admin)
      visit family_custom_field_properties_path(family, custom_field_id: custom_field_family.id)
    end

    feature 'List' do
      scenario 'Form title' do
        expect(page).to have_content(custom_field_family.form_title)
      end

      scenario 'Caseworker name' do
        expect(page).to have_content('John Doe')
      end
    end

    feature 'Create' do
      scenario 'valid' do
        click_link 'Add New'
        find('input[type="text"]').set('Jake')
        click_button 'Save'
        expect(page).to have_content('Jake')
        within("#custom_field_property_#{CustomFieldProperty.last.id}") do
          find('h5', text: admin.name)
        end
      end
    end

    feature 'Edit' do
      scenario 'valid' do
        within("#custom_field_property_#{custom_field_property_of_family.id}") do
          click_link(nil, href: edit_polymorphic_path([family, custom_field_property_of_family], custom_field_id: custom_field_family.id))
        end

        click_button 'Save'

        expect(page).to have_content(custom_field_family.form_title)
        expect(page).to have_content('John Doe')
      end
    end

    feature 'Delete' do
      scenario 'successful' do
        find("a[data-method='delete'][href='#{polymorphic_path([family, custom_field_property_of_family], custom_field_id: custom_field_family.id)}']").click

        expect(page).to have_content(custom_field_family.form_title)
        expect(page).not_to have_content('John Doe')
      end
    end

  end

  feature 'Partner' do
    before do
      login_as(admin)
      visit partner_custom_field_properties_path(partner, custom_field_id: custom_field_partner.id)
    end

    feature 'List' do
      scenario 'Form title' do
        expect(page).to have_content(custom_field_partner.form_title)
      end

      scenario 'Caseworker name' do
        expect(page).to have_content('John Doe')
      end
    end

    feature 'Create' do
      scenario 'valid' do
        click_link 'Add New'
        find('input[type="text"]').set('Jake')
        click_button 'Save'
        expect(page).to have_content('Jake')
        within("#custom_field_property_#{CustomFieldProperty.last.id}") do
          find('h5', text: admin.name)
        end
      end
    end

    feature 'Edit' do
      scenario 'valid' do
        within("#custom_field_property_#{custom_field_property_of_partner.id}") do
          click_link(nil, href: edit_polymorphic_path([partner, custom_field_property_of_partner], custom_field_id: custom_field_partner.id))
        end

        click_button 'Save'

        expect(page).to have_content(custom_field_partner.form_title)
        expect(page).to have_content('John Doe')
      end
    end

    feature 'Delete' do
      scenario 'successful' do
        find("a[data-method='delete'][href='#{polymorphic_path([partner, custom_field_property_of_partner], custom_field_id: custom_field_partner.id)}']").click

        expect(page).to have_content(custom_field_partner.form_title)
        expect(page).not_to have_content('John Doe')
      end
    end
  end

  feature 'User' do
    before do
      login_as(admin)
      visit user_custom_field_properties_path(user, custom_field_id: custom_field_user.id)
    end

    feature 'List' do
      scenario 'Form title' do
        expect(page).to have_content(custom_field_user.form_title)
      end

      scenario 'Caseworker name' do
        expect(page).to have_content('John Doe')
      end
    end

    feature 'Create' do
      scenario 'valid' do
        click_link 'Add New'
        find('input[type="text"]').set('Jake')
        click_button 'Save'
        expect(page).to have_content('Jake')
        within("#custom_field_property_#{CustomFieldProperty.last.id}") do
          find('h5', text: admin.name)
        end
      end
    end

    feature 'Edit' do
      scenario 'valid' do
        within("#custom_field_property_#{custom_field_property_of_user.id}") do
          click_link(nil, href: edit_polymorphic_path([user, custom_field_property_of_user], custom_field_id: custom_field_user.id))
        end

        click_button 'Save'

        expect(page).to have_content(custom_field_user.form_title)
        expect(page).to have_content('John Doe')
      end
    end

    feature 'Delete' do
      scenario 'successful' do
        find("a[data-method='delete'][href='#{polymorphic_path([user, custom_field_property_of_user], custom_field_id: custom_field_user.id)}']").click

        expect(page).to have_content(custom_field_user.form_title)
        expect(page).not_to have_content('John Doe')
      end
    end
  end
end
