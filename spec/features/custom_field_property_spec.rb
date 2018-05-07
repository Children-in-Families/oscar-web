feature 'custom_field_property' do
  let!(:admin){ create(:user, :admin) }
  let!(:user_1){ create(:user, :case_worker, first_name: 'John', last_name: 'Doe') }

  shared_examples 'create' do
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
  end

  shared_examples 'list' do
    feature 'List' do
      scenario 'Form title' do
        expect(page).to have_content(custom_field.form_title)
      end

      scenario 'Caseworker name' do
        expect(page).to have_content('John Doe')
      end
    end
  end

  shared_examples 'edit' do
    feature 'Edit' do
      scenario 'valid' do
        within("#custom_field_property_#{custom_field_property.id}") do
          click_link(nil, href: edit_polymorphic_path([custom_formable, custom_field_property], custom_field_id: custom_field.id))
        end

        click_button 'Save'

        expect(page).to have_content(custom_field.form_title)
        expect(page).to have_content('John Doe')
      end
    end
  end

  shared_examples 'delete' do
    feature 'Delete' do
      scenario 'successful' do
        find("a[data-method='delete'][href='#{polymorphic_path([custom_formable, custom_field_property], custom_field_id: custom_field.id)}']").click

        expect(page).to have_content(custom_field.form_title)
        expect(page).not_to have_content('John Doe')
      end
    end
  end

  shared_examples 'crud' do
    it_behaves_like 'list'
    it_behaves_like 'create'
    it_behaves_like 'edit'
    it_behaves_like 'delete'
  end

  feature 'Client' do
    let!(:custom_formable){ create(:client, :accepted) }
    let!(:custom_field){ create(:custom_field, entity_type: 'Client') }
    let!(:custom_field_property){ create(:custom_field_property, custom_formable_type: 'Client', custom_field: custom_field, custom_formable_id: custom_formable.id, user_id: user_1.id) }

    before do
      login_as(admin)
      visit polymorphic_path([custom_formable, CustomFieldProperty], custom_field_id: custom_field.id)
    end

    it_behaves_like 'crud'
  end

  feature 'Family' do
    let!(:custom_formable){ create(:family) }
    let!(:custom_field){ create(:custom_field, entity_type: 'Family') }
    let!(:custom_field_property){ create(:custom_field_property, custom_formable_type: 'Family', custom_field: custom_field, custom_formable_id: custom_formable.id, user_id: user_1.id) }

    before do
      login_as(admin)
      visit polymorphic_path([custom_formable, CustomFieldProperty], custom_field_id: custom_field.id)
    end

    it_behaves_like 'crud'
  end

  feature 'Partner' do
    let!(:custom_formable){ create(:partner) }
    let!(:custom_field){ create(:custom_field, entity_type: 'Partner') }
    let!(:custom_field_property){ create(:custom_field_property, custom_formable_type: 'Partner', custom_field: custom_field, custom_formable_id: custom_formable.id, user_id: user_1.id) }

    before do
      login_as(admin)
      visit polymorphic_path([custom_formable, CustomFieldProperty], custom_field_id: custom_field.id)
    end

    it_behaves_like 'crud'
  end

  feature 'User' do
    let!(:custom_formable){ create(:user) }
    let!(:custom_field){ create(:custom_field, entity_type: 'User') }
    let!(:custom_field_property){ create(:custom_field_property, custom_formable_type: 'User', custom_field: custom_field, custom_formable_id: custom_formable.id, user_id: user_1.id) }

    before do
      login_as(admin)
      visit polymorphic_path([custom_formable, CustomFieldProperty], custom_field_id: custom_field.id)
    end

    it_behaves_like 'crud'
  end
end
