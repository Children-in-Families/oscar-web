describe 'CaseNote' do
  let!(:user) { create(:user) }
  let!(:client) { create(:client,status: 'accepted', user: user) }
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
        find('.case-note-task-btn').click
        fill_in 'task_name', with: FFaker::Lorem.paragraph
        fill_in 'task_completion_date', with: Date.strptime(FFaker::Time.date).strftime('%B %d, %Y')
        find('.add-task-btn').trigger('click')
        sleep 1
      end
    end

    def remove_task(index)
      page.all('.task-arising a.remove-task')[index].click
    end

    scenario 'valid', js: true do
      fill_in 'case_note_meeting_date', with: Date.strptime(FFaker::Time.date).strftime('%B %d, %Y')
      fill_in 'Present', with: FFaker::Name.name
      fill_in 'Note', with: FFaker::Lorem.paragraph

      add_tasks(5)
      # remove_task(1)

      find('#case-note-submit-btn').click
      expect(page).to have_content('Case Note has successfully been created')
    end

    xscenario 'invalid' do
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'List' do
    let!(:case_note) { create(:case_note, client: client, assessment: assessment) }
    let!(:case_note_domain_group) { create(:case_note_domain_group, case_note: case_note, domain_group: domain.domain_group) }
    let!(:other_client) { create(:client,status: 'accepted', user: user) }
    let!(:other_fc_case){ create(:case, case_type: 'FC', client: other_client) }

    before do
      visit client_case_notes_path(client)
    end

    scenario 'link new case note' do
      expect(page).to have_link('New case note', href: new_client_case_note_path(client))
    end

    scenario 'case note date' do
      expect(page).to have_content case_note.meeting_date.strftime('%B %d, %Y')
    end

    scenario 'case note domain' do
      expect(page).to have_content domain.identity
    end

    scenario 'case note score' do
      expect(page.find('.label')).to have_content assessment_domain.score
    end

    scenario 'case note content' do
      expect(page).to have_content case_note_domain_group.note
    end

    scenario 'no assessment' do
      expect(page).not_to have_link(nil, href: new_client_case_note_path(other_client))
    end
  end


end
