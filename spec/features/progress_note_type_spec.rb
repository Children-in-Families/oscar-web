describe 'ProgressNoteType' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:progress_note_type){ create(:progress_note_type, note_type: 'AAA') }
  let!(:used_progress_note_type){ create(:progress_note_type) }
  let!(:location){ create(:location, name: 'ផ្សេងៗ Other') }
  let!(:progress_note){ create(:progress_note, progress_note_type: used_progress_note_type, location: location) }

  before do
    login_as(admin)
  end

  feature 'List' do
    before do
      FactoryGirl.create_list(:progress_note_type, 20)
      visit progress_note_types_path
    end

    scenario 'note type' do
      expect(page).to have_content(progress_note_type.note_type)
    end

    scenario 'edit link' do
      expect(page).to have_link(nil, edit_progress_note_type_path(progress_note_type))
    end

    scenario 'delete link' do
      expect(page).to have_css("a[href='#{progress_note_type_path(progress_note_type)}'][data-method='delete']")
    end

    scenario 'new link' do
      expect(page).to have_link(I18n.t('progress_note_types.index.add_new_progress_note_type'), new_progress_note_type_path)
    end

    scenario 'pagination' do
      expect(page).to have_css('.pagination')
    end
  end

  feature 'Create', js: true do
    before do
      visit progress_note_types_path
    end

    scenario 'valid' do
      click_link('New Type of Note')
      within('#new_progress_note_type') do
        fill_in I18n.t('progress_note_types.form.note_type'), with: FFaker::Lorem.word
        click_button I18n.t('progress_note_types.form.save')
      end
      sleep 1
      expect(page).to have_content(I18n.t('progress_note_types.create.successfully_created'))
    end

    scenario 'invalid' do
      click_link('New Type of Note')
      within('#new_progress_note_type') do
        click_button I18n.t('progress_note_types.form.save')
      end
      sleep 1
      expect(page).to have_content('Failed to create a type of note.')
    end
  end

  feature 'Edit', js: true do
    let!(:note_type) { FFaker::Lorem.word }
    let!(:other_progress_note_type) { create(:progress_note_type, note_type: 'Progress Note') }
    before do
      visit progress_note_types_path
    end
    scenario 'valid' do
      find("a[data-target='#progress_note_typeModal-#{other_progress_note_type.id}']").click
      within("#progress_note_typeModal-#{other_progress_note_type.id}") do
        fill_in I18n.t('progress_note_types.form.note_type'), with: note_type
        click_button I18n.t('progress_note_types.form.save')
      end
      sleep 1
      expect(page).to have_content(I18n.t('progress_note_types.update.successfully_updated'))
      expect(page).to have_content(note_type)
    end
    scenario 'invalid' do
      find("a[data-target='#progress_note_typeModal-#{other_progress_note_type.id}']").click
      within("#progress_note_typeModal-#{other_progress_note_type.id}") do
        click_button I18n.t('progress_note_types.form.save')
      end
      sleep 1
      expect(page).to have_content('Type of Note has been successfully updated.')
    end
  end

  feature 'Delete', js: true do
    before do
      visit progress_note_types_path
    end
    scenario 'success' do
      find("a[href='#{progress_note_type_path(progress_note_type)}'][data-method='delete']").click
      sleep 1
      expect(page).to have_content(I18n.t('progress_note_types.destroy.successfully_deleted'))
    end

    scenario 'does not succeed' do
      expect(page).to have_css("a[href='#{progress_note_type_path(used_progress_note_type)}'][data-method='delete'][class='btn btn-outline btn-danger btn-xs disabled']")
    end
  end
end
