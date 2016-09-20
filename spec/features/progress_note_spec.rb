describe 'progress_note' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:client){ create(:client) }
  let!(:progress_note){ create(:progress_note) }
  let!(:location){ create(:location) }
  let!(:intervention){ create(:intervention) }
  let!(:material){ create(:material) }

  before do
    login_as(admin)
  end

  # feature 'List' do
  #   before do
  #     FactoryGirl.create_list(:progress_note, 20)
  #     visit progress_notes_path
  #   end

  #   scenario 'date' do
  #     expect(page).to have_content(progress_note.date)
  #   end

  #   scenario 'edit link' do
  #     expect(page).to have_link(nil, edit_progress_note_path(progress_note))
  #   end

  #   scenario 'delete link' do
  #     expect(page).to have_css("a[href='#{progress_note_path(progress_note)}'][data-method='delete']")
  #   end

  #   scenario 'new link' do
  #     expect(page).to have_link(I18n.t('progress_notes.index.add_new_progress_note'), new_progress_note_path)
  #   end

  #   scenario 'pagination' do
  #     expect(page).to have_css('.pagination')
  #   end
  # end

  feature 'Create' do
    before do
      visit new_client_progress_note_path(client)
    end

    scenario 'valid' do
      fill_in I18n.t('progress_notes.form.date'), with: FFaker::Time.date
      select progress_note.note_type, from: I18n.t('progress_notes.form.progress_note_type')
      select location.name, from: I18n.t('progress_notes.form.location')
      find(:css, "#intervention_progress_note_ids[value='#{intervention.id}']").set(true)
      select material.status, from: I18n.t('progress_notes.form.material')

      click_button I18n.t('progress_notes.form.save')
      expect(page).to have_content(I18n.t('progress_notes.create.successfully_created'))
    end

    # scenario 'invalid' do
    #   click_button I18n.t('progress_notes.form.save')
    #   expect(page).to have_content("can't be blank")
    # end
  end

  # feature 'Edit' do
  #   let!(:name) { FFaker::Company.name }
  #   let!(:other_progress_note) { create(:progress_note, name: 'Home') }
  #   before do
  #     visit edit_progress_note_path(progress_note)
  #   end
  #   scenario 'valid' do
  #     fill_in I18n.t('progress_notes.form.name'), with: name
  #     click_button I18n.t('progress_notes.form.save')
  #     expect(page).to have_content(I18n.t('progress_notes.update.successfully_updated'))
  #     expect(page).to have_content(name)
  #   end
  #   scenario 'invalid' do
  #     fill_in I18n.t('progress_notes.form.name'), with: 'Home'
  #     click_button I18n.t('progress_notes.form.save')
  #     expect(page).to have_content(I18n.t('activerecord.errors.models.progress_note.attributes.name.taken'))
  #   end
  # end

  # feature 'Delete' do
  #   before do
  #     visit progress_notes_path
  #   end
  #   scenario 'success' do
  #     find("a[href='#{progress_note_path(progress_note)}'][data-method='delete']").click
  #     expect(page).to have_content(I18n.t('progress_notes.destroy.successfully_deleted'))
  #   end
  # end
end
