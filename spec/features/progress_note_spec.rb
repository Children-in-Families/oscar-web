feature 'progress_note' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:client){ create(:client, able_state: Client::ABLE_STATES[0]) }
  let!(:other_location){ create(:location, name: 'ផ្សេងៗ Other') }
  let!(:progress_note){ create(:progress_note, client: client, location: other_location) }
  let!(:other_progress_note){ create(:progress_note, client: client, location: other_location) }
  let!(:progress_note_type){ create(:progress_note_type) }
  let!(:location){ create(:location) }
  let!(:intervention){ create(:intervention) }
  let!(:material){ create(:material) }
  let!(:user){ create(:user) }
  let!(:attachment){ create(:attachment, progress_note: progress_note, file: Rack::Test::UploadedFile.new('spec/supports/file.docx', 'application/zip')) }

  before do
    login_as(admin)
  end

  feature 'Show' do
    before do
      visit client_progress_note_path(progress_note.client, progress_note)
    end

    scenario 'attachments' do
      expect(page).to have_link('Download', client_progress_note_path(client, progress_note, attachment))
    end

    scenario 'all info' do
      progress_note_info
    end

    scenario 'date formated' do
      expect(page).to have_content(progress_note.decorate.date.strftime('%d %B, %Y'))
    end

    scenario 'activities/response' do
      expect(page).to have_content(progress_note.response)
    end

    scenario 'additional notes' do
      expect(page).to have_content(progress_note.additional_note)
    end

    scenario 'edit link' do
      expect(page).to have_link(nil, edit_client_progress_note_path(progress_note.client, progress_note))
    end

    scenario 'delete link' do
      expect(page).to have_css("a[href='#{client_progress_note_path(progress_note.client, progress_note)}'][data-method='delete']")
    end

    scenario 'back link' do
      expect(page).to have_link(I18n.t('progress_notes.show.back'), client_progress_notes_path(progress_note.client))
    end
  end

  feature 'List' do
    before do
      FactoryGirl.create_list(:progress_note, 20, client: client)
      visit client_progress_notes_path(progress_note.client)
    end

    scenario 'all info' do
      progress_note_info
    end

    scenario 'date and link to show page' do
      expect(page).to have_content(progress_note.date.strftime('%d %b, %Y'))
      expect(page).to have_link(progress_note.date.strftime('%d %b, %Y'), client_progress_note_path(progress_note.client, progress_note))
    end

    scenario 'edit link' do
      expect(page).to have_link(nil, edit_client_progress_note_path(progress_note.client, progress_note))
    end

    scenario 'delete link' do
      expect(page).to have_css("a[href='#{client_progress_note_path(progress_note.client, progress_note)}'][data-method='delete']")
    end

    scenario 'new link' do
      expect(page).to have_link(I18n.t('progress_notes.index.add_new_progress_note'), new_client_progress_note_path(progress_note.client))
    end

    scenario 'pagination' do
      expect(page).to have_css('.pagination')
    end
  end

  feature 'Create' do
    before do
      visit new_client_progress_note_path(client)
    end

    xscenario 'valid', js: true do
      fill_in I18n.t('progress_notes.form.date'), with: FFaker::Time.date
      # select progress_note_type.note_type, from: I18n.t('progress_notes.form.progress_note_type')
      # select location.name, from: I18n.t('progress_notes.form.location').last
      # select intervention.action, from: I18n.t('progress_notes.form.interventions')
      # select material.status, from: I18n.t('progress_notes.form.material')
      # fill_in I18n.t('progress_notes.form.other_location'), with: 'test'
      page.find('#select2-chosen-2').click
      page.find('#select2-result-label-6').click
      click_button I18n.t('progress_notes.form.save')
      sleep 1
      expect(page).to have_content(I18n.t('progress_notes.create.successfully_created'))
    end

    scenario 'invalid', js: true do
      fill_in 'Date', with: ''
      page.find("#only-submit").click
      expect(page).to have_content(I18n.t('activerecord.errors.models.progress_note.attributes.date.blank'))
    end
  end

  feature 'Edit' do
    before do
      visit edit_client_progress_note_path(other_progress_note.client, other_progress_note)
    end
    scenario 'valid', js: true do
      date = Date.today
      fill_in I18n.t('progress_notes.form.date'), with: date.to_s
      click_button I18n.t('progress_notes.form.save')
      sleep 1
      expect(page).to have_content(I18n.t('progress_notes.update.successfully_updated'))
      expect(page).to have_content(date.strftime('%d %B, %Y'))
    end
    scenario 'invalid', js: true do
      fill_in I18n.t('progress_notes.form.date'), with: ''
      click_button I18n.t('progress_notes.form.save')
      expect(page).to have_content(I18n.t('activerecord.errors.models.progress_note.attributes.date.blank'))
    end
  end

  feature 'Delete', js: true do
    before do
      visit client_progress_notes_path(progress_note.client)
    end
    scenario 'success' do
      find("a[href='#{client_progress_note_path(progress_note.client, progress_note)}'][data-method='delete']").click
      sleep 1
      expect(page).to have_content(I18n.t('progress_notes.destroy.successfully_deleted'))
    end
  end
end
