describe 'CaseNote' do
  let!(:user) { create(:user) }
  let!(:client) { create(:client, :accepted, users: [user]) }
  let!(:fc_case){ create(:case, case_type: 'FC', client: client) }
  let!(:domain){ create(:domain, name: '1A') }
  let!(:assessment){ create(:assessment, client: client) }
  let!(:assessment_domain){ create(:assessment_domain, assessment: assessment, domain: domain) }

  before do
    login_as(user)
  end

  feature 'Create' do
    before do
      visit new_client_case_note_path(client)
    end

    def add_tasks(n)
      (1..n).each do |time|
        find('.case-note-task-btn').trigger('click')
        fill_in 'task_name', with: 'ABC'
        fill_in 'task_completion_date', with: date_format(Date.strptime(FFaker::Time.date))
        find('.add-task-btn').trigger('click')
        sleep 1
      end
    end

    def remove_task(index)
      page.all('.task-arising a.remove-task')[index].trigger('click')
    end

    scenario 'valid', js: true do
      fill_in 'case_note_meeting_date', with: '2017-04-01'
      fill_in 'Who was there during the visit or conversation?', with: 'Jonh'
      find("#case_note_interaction_type option[value='Visit']", visible: false).select_option
      fill_in 'Note', with: 'This is valid'

      add_tasks(1)
      find('#case-note-submit-btn').trigger('click')

      sleep 1
      expect(page).to have_content('01 April 2017')
      expect(page).to have_content('Jonh')
      expect(page).to have_content('This is valid')
      expect(Task.find_by(name: 'ABC').user_id).to eq(user.id)
    end

    xscenario 'invalid' do
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end

    context 'case notes permissions' do
      scenario 'user has editable permission' do
        expect(new_client_case_note_path(client)).to have_content(current_path)
      end

      scenario 'user does not have editable permission' do
        user.permission.update(case_notes_editable: false)
        visit new_client_case_note_path(client)
        expect(dashboards_path).to have_content(current_path)
      end
    end
  end

  feature 'List' do
    let!(:case_note) { create(:case_note, client: client, assessment: assessment) }
    let!(:case_note_domain_group) { create(:case_note_domain_group, case_note: case_note, domain_group: domain.domain_group) }
    let!(:other_client) { create(:client,status: 'accepted', users: [user]) }
    let!(:other_fc_case){ create(:case, case_type: 'FC', client: other_client) }

    before do
      visit client_case_notes_path(client)
    end

    context 'New Case note link' do
      let(:default_csi){ Setting.first.default_assessment }
      let(:custom_csi){ Setting.first.custom_assessment }
      let!(:custom_domain){ create(:domain, :custom) }

      context 'only one csi tool is enable' do
        scenario 'default csi' do
          Setting.first.update(enable_default_assessment: true, enable_custom_assessment: false)
          visit client_case_notes_path(client)

          expect(page).to have_link('New case note', href: new_client_case_note_path(client, custom: false))
        end
        scenario 'custom csi', js: true do
          Setting.first.update(enable_default_assessment: false, enable_custom_assessment: true)
          visit client_case_notes_path(client)
          expect(page).to have_link('New case note', href: new_client_case_note_path(client, custom: true))
        end
      end
      scenario 'both csi tools are enable', js: true do
        Setting.first.update(enable_custom_assessment: true)
        visit client_case_notes_path(client)
        click_on 'New case note'
        expect(page).to have_link(default_csi, href: new_client_case_note_path(client, custom: false))
        expect(page).to have_link(custom_csi, href: new_client_case_note_path(client, custom: true))
      end
    end

    scenario 'case note date' do
      expect(page).to have_content date_format(case_note.meeting_date)
    end

    scenario 'case note domain' do
      expect(page).to have_content domain.identity
    end

    scenario 'case note score' do
      expect(page).to have_content assessment_domain.score
    end

    scenario 'case note content' do
      expect(page).to have_content case_note_domain_group.note
    end

    scenario 'no assessment' do
      expect(page).not_to have_link(nil, href: new_client_case_note_path(other_client))
    end

    context 'case notes permission' do
      scenario 'user has readable permission' do
        expect(client_case_notes_path(client)).to have_content(current_path)
      end

      scenario 'user does not have readable permission' do
        user.permission.update(case_notes_readable: false)
        visit client_case_notes_path(client)
        expect(dashboards_path).to have_content(current_path)
      end
    end
  end

  feature 'Update' do
    let!(:case_note) { create(:case_note, client: client, assessment: assessment) }

    context 'case notes editable permission' do
      scenario 'user has editable permission' do
        visit edit_client_case_note_path(client, case_note)
        expect(edit_client_case_note_path(client, case_note)).to have_content(current_path)
      end

      scenario 'user does not have editable permission' do
        user.permission.update(case_notes_editable: false)
        visit edit_client_case_note_path(client, case_note)
        expect(dashboards_path).to have_content(current_path)
      end
    end
  end
end
