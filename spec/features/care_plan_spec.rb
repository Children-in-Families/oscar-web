describe 'Care Plan' do
  let!(:admin){ create(:user, :admin) }
  let!(:user){ create(:user) }
  let!(:family) { create(:family, :active, user: user) }
  let!(:client) { create(:client, :accepted, users: [user]) }
  let!(:fc_case){ create(:case, case_type: 'FC', client: client) }
  let!(:domain_group){ create(:domain_group) }
  let!(:domain_1){ create(:domain, score_1_color: 'danger', score_1_definition: 'Poor', score_2_color: 'warning', score_2_definition: 'Good', domain_group:domain_group) }
  let!(:assessment_1){ create(:assessment, :custom, client: client, created_at: 6.months.ago) }
  let!(:assessment_2){ create(:assessment, :custom, family: family, created_at: 6.months.ago) }
  let!(:assessment_domain_1){ create(:assessment_domain, assessment: assessment_1, domain: domain_1, score: 1, reason:'test', goal: 'riri') }
  let!(:assessment_domain_2){ create(:assessment_domain, assessment: assessment_2, domain: domain_1, score: 1, reason:'test', goal: 'riri') }

    before do
      login_as(admin)
    end

    feature 'Create', js: true do

    before do
      visit new_client_care_plan_path(client.id, :assessment => assessment_1.id)
      expect(page).to have_content('Score from assessment')
    end

    scenario 'Incompleted for client', js: true do
      click_link "Finish"
      expect(page).to have_content('Incompleted')
    end

    scenario 'Completed for client', js: true do
      text_area = first(:css, 'textarea.goal-input-field').native
      text_area.set('Test')
      task = find('.task-input-field').native
      task.set('Testing Task')
      page.execute_script("$('#task_completion_date').val('2022-03-09')")
      click_link "Finish"
      expect(page).to have_content('Completed')
      expect(page).to have_content("Care plan created on #{date_format(Date.today)}")
    end

    scenario 'Incompleted for family', js: true do
      visit new_family_care_plan_path(family.id, :assessment => assessment_2.id)
      click_link "Finish"
      expect(page).to have_content('Incompleted')
    end

    scenario 'Completed for family', js: true do
      visit new_family_care_plan_path(family.id, :assessment => assessment_2.id)
      text_area = first(:css, 'textarea.goal-input-field').native
      text_area.set('Test')
      task = find('.task-input-field').native
      task.set('Testing Task')
      page.execute_script("$('#task_completion_date').val('2022-03-09')")
      click_link "Finish"
      expect(page).to have_content('Completed')
      expect(page).to have_content("Care plan created on #{date_format(Date.today)}")
    end

    scenario 'Task List should be increase by one after user click on button Add Task', js: true do
      find('a', text: 'Add task', exact: true).click
      expect(all('div.task-form.nested-fields').count).to be == 2
      expect(page).to have_content('Add goal')
    end

    scenario 'Task List should be equal 1 by defauls', js: true do
      expect(all('div.task-form.nested-fields').count).to be == 1
      expect(page).to have_content('Add goal')
    end

    scenario 'Goal input type must be textarea and must be only one from the begining of loading page', js:true do
      expect(all('textarea.goal-input-field').count).to be == 1
    end

    scenario 'Input fields should be valid all, Goal, Task, Task Date must be vaild and datatype as string', js: true do
      headers = { "ACCEPT" => "application/json" }
      find('.goal-input-field')
      text_area = first(:css, 'textarea.goal-input-field').native
      text_area.send_keys('Test')
      find('.task-input-field').set('Testing Task')
      find('.task-date-field').set('2022-03-09')
    end
  end
end

