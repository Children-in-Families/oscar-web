describe 'Task' do
  let!(:user){ create(:user, :admin, calendar_integration: true) }
  let!(:client){ create(:client, users: [user], code: rand(1000..2000).to_s) }
  let!(:domain){ create(:domain) }
  let!(:overdue_task){ create(:task, client: client, completion_date: Date.today - 6.month) }
  let!(:today_task){ create(:task, client: client, completion_date: Date.today) }
  let!(:upcoming_task){ create(:task, client: client, completion_date: Date.today + 6.month) }
  let!(:incomplete_task){ create(:task, completed: false) }
  before do
    login_as(user)
  end
  feature 'List' do
    before do
      visit client_tasks_path(client)
    end
    scenario 'overdue task' do
      panel = page.all(:css, '.panel').select { |p| p.all(:css, '.panel-heading').select { |pp| pp.text.include?('Overdue Tasks') }.first }.first
      expect(panel).to have_content(overdue_task.name)
      expect(panel).to have_content(overdue_task.domain.name)
      expect(panel).to have_content(overdue_task.completion_date.strftime("%d %B %Y"))
    end
    scenario 'today task' do
      panel = page.all(:css, '.panel').select { |p| p.all(:css, '.panel-heading').select { |pp| pp.text.include?('Today Tasks') }.first }.first
      expect(panel).to have_content(today_task.name)
      expect(panel).to have_content(today_task.domain.name)
      expect(panel).to have_content(today_task.completion_date.strftime("%d %B %Y"))
    end
    scenario 'upcoming task' do
      panel = page.all(:css, '.panel').select { |p| p.all(:css, '.panel-heading').select { |pp| pp.text.include?('Upcoming Tasks') }.first }.first
      expect(panel).to have_content(upcoming_task.name)
      expect(panel).to have_content(upcoming_task.domain.name)
      expect(panel).to have_content(upcoming_task.completion_date.strftime("%d %B %Y"))
    end
    scenario 'edit link' do
      expect(page).to have_link(nil, href: edit_client_task_path(client, overdue_task))
      expect(page).to have_link(nil, href: edit_client_task_path(client, today_task))
      expect(page).to have_link(nil, href: edit_client_task_path(client, upcoming_task))
    end
    scenario 'delete link' do
      expect(page).to have_css("a[href='#{client_task_path(client, overdue_task)}'][data-method='delete']")
      expect(page).to have_css("a[href='#{client_task_path(client, today_task)}'][data-method='delete']")
      expect(page).to have_css("a[href='#{client_task_path(client, upcoming_task)}'][data-method='delete']")
    end

    scenario 'new link' do
      expect(page).not_to have_link('New Task')
    end

    scenario 'no incomplete task' do
      expect(page).not_to have_content(incomplete_task)
    end
  end

  feature 'Update' do
    before do
      visit edit_client_task_path(client, upcoming_task)
    end
    scenario 'valid', js: true do
      fill_in 'Enter task details', with: 'Task Updated'
      click_button 'Save'
      sleep 1
      expect(page).to have_content('Task Updated')
    end
    scenario 'invalid' do
      fill_in 'Enter task details', with: ''
      click_button 'Save'
      expect(page).to have_content("Please review the problems below")
    end
  end

  feature 'Delete', js: true do
    before do
      visit client_tasks_path(client)
    end
    scenario 'successful' do
      find("a[href='#{client_task_path(client, overdue_task)}'][data-method='delete']").click
      sleep 1
      expect(page).to have_content('Task has successfully been deleted')
    end
  end
end
