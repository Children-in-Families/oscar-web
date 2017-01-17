describe Task do
  let!(:admin)            { create(:user, roles: 'admin', first_name: 'mr', last_name: 'admin') }

  let!(:able_department)  { create(:department, :able)}
  let!(:kc_department)    { create(:department, :kinship_care)}

  let!(:able_manager)     { create(:user, :able_manager, department: able_department, first_name: 'able', last_name: 'manager') }
  let!(:able_caseworker)  { create(:user, department: able_department, first_name: 'able', last_name: 'caseworker') }
  let!(:kc_caseworker)    { create(:user, department: kc_department, first_name: 'kc', last_name: 'caseworker') }

  let!(:client){ create(:client, user: able_caseworker) }
  let!(:client2){ create(:client, user: able_manager) }

  let!(:overdue_task){ create(:task, client: client, completion_date: Date.today - 6.month) }
  let!(:upcoming_task){ create(:task, client: client2, completion_date: Date.today + 6.month) }

  feature 'User tasks' do
    feature 'Log in as Admin' do
      before do
        login_as(admin)
        visit clients_path
      end

      scenario 'list all users from all department' do
        click_link 'View All Active Tasks'
        expect(page).to have_select 'user_id', with_options: ['mr admin', 'able manager', 'able caseworker', 'kc caseworker']
      end

      scenario 'list manager task', js: true do
        click_link 'View All Active Tasks'
        expect(page).to have_select 'user_id', with_options: ['mr admin', 'able manager', 'able caseworker', 'kc caseworker']
        select 'able manager'
        sleep 1
        panel = page.all(:css, '.panel').select { |p| p.all(:css, '.panel-heading').select { |pp| pp.text.include?('Upcoming Tasks') }.first }.first
        expect(panel).to have_content(upcoming_task.name)
      end

      scenario 'list caseworker task', js: true do
        click_link 'View All Active Tasks'
        expect(page).to have_select 'user_id', with_options: ['mr admin', 'able manager', 'able caseworker', 'kc caseworker']
        select 'able caseworker'
        sleep 1
        panel = page.all(:css, '.panel').select { |p| p.all(:css, '.panel-heading').select { |pp| pp.text.include?('Overdue Tasks') }.first }.first
        expect(panel).to have_content(overdue_task.name)
      end
    end

    feature 'Log in as Manager' do
      before do
        login_as(able_manager)
        visit clients_path
      end

      scenario 'list all caseworker and manager under departments' do
        click_link 'View All Active Tasks'
        expect(page).to have_select 'user_id', with_options: ['able manager', 'able caseworker']
      end

      scenario 'list manager task', js: true do
        click_link 'View All Active Tasks'
        expect(page).to have_select 'user_id', with_options: ['able manager', 'able caseworker']
        panel = page.all(:css, '.panel').select { |p| p.all(:css, '.panel-heading').select { |pp| pp.text.include?('Upcoming Tasks') }.first }.first
        expect(panel).to have_content(upcoming_task.name)
      end

      scenario 'list caseworker task', js: true do
        click_link 'View All Active Tasks'
        expect(page).to have_select 'user_id', with_options: ['able manager', 'able caseworker']
        select 'able caseworker'
        sleep 1
        panel = page.all(:css, '.panel').select { |p| p.all(:css, '.panel-heading').select { |pp| pp.text.include?('Overdue Tasks') }.first }.first
        expect(panel).to have_content(overdue_task.name)
      end
    end

    feature 'Log in as Caseworker' do
      before do
        login_as(able_caseworker)
        visit clients_path
      end

      scenario 'display only caseworker task' do
        click_link 'View All Active Tasks'
        panel = page.all(:css, '.panel').select { |p| p.all(:css, '.panel-heading').select { |pp| pp.text.include?('Overdue Tasks') }.first }.first
        expect(panel).to have_content(overdue_task.name)
      end

      scenario 'unable to use filter by user' do
        click_link 'View All Active Tasks'
        expect(page).not_to have_select 'user_id'
      end
    end
  end
end
