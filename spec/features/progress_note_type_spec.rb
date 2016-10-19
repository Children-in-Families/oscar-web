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

  feature 'Create' do
    before do
      visit new_progress_note_type_path
    end

    scenario 'valid' do
      fill_in I18n.t('progress_note_types.form.note_type'), with: FFaker::Lorem.word
      click_button I18n.t('progress_note_types.form.save')
      expect(page).to have_content(I18n.t('progress_note_types.create.successfully_created'))
    end

    scenario 'invalid' do
      click_button I18n.t('progress_note_types.form.save')
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Edit' do
    let!(:note_type) { FFaker::Lorem.word }
    let!(:other_progress_note_type) { create(:progress_note_type, note_type: 'Progress Note') }
    before do
      visit edit_progress_note_type_path(progress_note_type)
    end
    scenario 'valid' do
      fill_in I18n.t('progress_note_types.form.note_type'), with: note_type
      click_button I18n.t('progress_note_types.form.save')
      expect(page).to have_content(I18n.t('progress_note_types.update.successfully_updated'))
      expect(page).to have_content(note_type)
    end
    scenario 'invalid' do
      fill_in I18n.t('progress_note_types.form.note_type'), with: 'Progress Note'
      click_button I18n.t('progress_note_types.form.save')
      expect(page).to have_content(I18n.t('activerecord.errors.models.progress_note_type.attributes.note_type.taken'))
    end
  end

  feature 'Delete' do
    before do
      visit progress_note_types_path
    end
    scenario 'success' do
      find("a[href='#{progress_note_type_path(progress_note_type)}'][data-method='delete']").click
      expect(page).to have_content(I18n.t('progress_note_types.destroy.successfully_deleted'))
    end

    scenario 'does not succeed' do
      expect(page).not_to have_css("a[href='#{progress_note_type_path(used_progress_note_type)}'][data-method='delete']")
    end
  end
end
