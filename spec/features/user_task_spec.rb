describe Task do
  let!(:admin)           { create(:user, roles: 'admin', first_name: 'mr', last_name: 'admin') }
  let!(:manager)         { create(:user, :manager, first_name: 'manager') }
  let!(:able_manager)    { create(:user, :able_manager, first_name: 'able', last_name: 'manager') }
  let!(:ec_manager)      { create(:user, :ec_manager, first_name: 'ec manager') }
  let!(:fc_manager)      { create(:user, :fc_manager, first_name: 'fc manager') }
  let!(:kc_manager)      { create(:user, :kc_manager, first_name: 'kc manager') }
  let!(:able_caseworker) { create(:user, first_name: 'able', last_name: 'caseworker') }
  let!(:ec_caseworker)   { create(:user, first_name: 'ec', last_name: 'caseworker') }
  let!(:fc_caseworker)   { create(:user, first_name: 'fc', last_name: 'caseworker') }
  let!(:kc_caseworker)   { create(:user, first_name: 'kc', last_name: 'caseworker') }
  let!(:subordinate)     { create(:user, :case_worker, first_name: 'subordinate', manager_id: manager.id) }

  let!(:able_client)     { create(:client, users: [able_caseworker], able_state: 'Accepted') }
  let!(:client2)         { create(:client, users: [able_manager]) }
  let!(:ec_client)       { create(:client, status: 'Active', users: [ec_caseworker]) }
  let!(:fc_client)       { create(:client, status: 'Active', users: [fc_caseworker]) }
  let!(:kc_client)       { create(:client, status: 'Active', users: [kc_caseworker]) }
  let!(:sub_client)      { create(:client, users: [subordinate]) }

  let!(:ec_task)   { create(:task, client: ec_client) }
  let!(:fc_task)   { create(:task, client: fc_client) }
  let!(:kc_task)   { create(:task, client: kc_client) }
  let!(:sub_task)  { create(:task, client: sub_client) }
  let!(:able_task) { create(:task, client: able_client) }

  let!(:overdue_task)    { create(:task, user: able_caseworker, client: able_client, completion_date: Date.today - 6.month) }
  let!(:upcoming_task)   { create(:task, client: client2, completion_date: Date.today + 6.month) }

  feature 'User tasks' do
    feature 'Log in as Admin' do
      before do
        login_as(admin)
        visit dashboards_path
      end

      scenario 'list all users' do
        expect(page).to have_select 'user_id', with_options: ['mr admin', 'able manager', 'able caseworker', 'ec caseworker']
      end

      xscenario 'list manager task', js: true do
        page.find('.widget-tasks-panel').click
        sleep 1
        expect(page).to have_select 'user_id', with_options: ['mr admin', 'able manager', 'able caseworker', 'ec caseworker'], visible: false
        find("select#user_id option[value='#{able_manager.id}']", visible: false).select_option
        sleep 1
        page.find('.widget-tasks-panel').click
        sleep 1
        panel = page.all(:css, '.panel').select { |p| p.all(:css, '.panel-heading').select { |pp| pp.text.include?('Upcoming tasks') }.first }.first
        expect(panel).to have_content(upcoming_task.name)
        expect(page).to have_link(client2.name, href: client_path(client2))
      end

      xscenario 'list caseworker task', js: true do
        page.find('.widget-tasks-panel').click
        expect(page).to have_select 'user_id', with_options: ['mr admin', 'able manager', 'able caseworker', 'ec caseworker'], visible: false
        find("select#user_id option[value='#{able_caseworker.id}']", visible: false).select_option
        sleep 1
        page.find('.widget-tasks-panel').click
        sleep 1
        panel = page.all(:css, '.panel').select { |p| p.all(:css, '.panel-heading').select { |pp| pp.text.include?('Overdue tasks') }.first }.first
        expect(panel).to have_content(overdue_task.name)
      end
    end

    feature 'Log in as Able Manager' do
      before do
        login_as(able_manager)
        visit dashboards_path
      end

      scenario 'list all able managers and case worker of able clients' do
        expect(page).to have_select 'user_id', with_options: ['able manager', 'able caseworker']
      end

      xscenario 'list manager task', js: true do
        page.find('.widget-tasks-panel').click
        expect(page).to have_select 'user_id', with_options: ['able manager', 'able caseworker'], visible: false
        find("select#user_id option[value='#{able_manager.id}']", visible: false).select_option
        sleep 1
        page.find('.widget-tasks-panel').click
        sleep 1
        panel = page.all(:css, '.panel').select { |p| p.all(:css, '.panel-heading').select { |pp| pp.text.include?('Upcoming tasks') }.first }.first
        expect(panel).to have_content(upcoming_task.name)
      end

      xscenario 'list caseworker task', js: true do
        page.find('.widget-tasks-panel').click
        expect(page).to have_select 'user_id', with_options: ['able manager', 'able caseworker'], visible: false
        find("select#user_id option[value='#{able_caseworker.id}']", visible: false).select_option
        sleep 1
        page.find('.widget-tasks-panel').click
        sleep 1
        panel = page.all(:css, '.panel').select { |p| p.all(:css, '.panel-heading').select { |pp| pp.text.include?('Overdue tasks') }.first }.first
        expect(panel).to have_content(overdue_task.name)
      end

      xscenario 'list able case worker task', js: true do
        find("select#user_id option[value='#{able_caseworker.id}']", visible: false).select_option
        sleep 1
        page.find('.widget-tasks-panel').click
        expect(page).to have_content(able_task.name)
      end
    end

    feature 'Log in as Caseworker' do
      before do
        login_as(able_caseworker)
        visit dashboards_path
      end

      xscenario 'display only caseworker task', js: true do
        panel = page.all(:css, '.panel').select { |p| p.all(:css, '.panel-heading').select { |pp| pp.text.include?('Overdue tasks') }.first }.first
        page.find('.widget-tasks-panel').click
        expect(panel).to have_content(overdue_task.name)
      end

      scenario 'unable to use filter by user' do
        expect(page).not_to have_select 'user_id'
      end
    end

    feature 'Log in as EC Manager' do
      before do
        login_as(ec_manager)
        visit dashboards_path
      end

      scenario 'list ec managers and case worker of Active EC clients' do
        expect(page).to have_select 'user_id', with_options: ['ec manager']
      end

      xscenario 'list ec case worker task', js: true do
        find("select#user_id option[value='#{ec_caseworker.id}']", visible: false).select_option
        sleep 1
        page.find('.widget-tasks-panel').click
        expect(page).to have_content(ec_task.name)
      end
    end

    feature 'Log in as FC Manager' do
      before do
        login_as(fc_manager)
        visit dashboards_path
      end

      scenario 'list fc managers and case worker of Active FC clients' do
        expect(page).to have_select 'user_id', with_options: ['fc manager']
      end

      xscenario 'list fc case worker task', js: true do
        find("select#user_id option[value='#{fc_caseworker.id}']", visible: false).select_option
        sleep 1
        page.find('.widget-tasks-panel').click
        expect(page).to have_content(fc_task.name)
      end
    end

    feature 'Log in as KC Manager' do
      before do
        login_as(kc_manager)
        visit dashboards_path
      end

      scenario 'list kc managers and case worker of Active KC clients' do
        expect(page).to have_select 'user_id', with_options: ['kc manager']
      end

      xscenario 'list kc case worker task', js: true do
        find("select#user_id option[value='#{kc_caseworker.id}']", visible: false).select_option
        sleep 1
        page.find('.widget-tasks-panel').click
        expect(page).to have_content(kc_task.name)
      end
    end

    feature 'Log in as Manager' do
      before do
        login_as(manager)
        visit dashboards_path
      end

      scenario 'list managers and their subordinates' do
        expect(page).to have_select 'user_id', with_options: ['manager', 'subordinate']
      end

      xscenario 'list subordinate task', js: true do
        find("select#user_id option[value='#{subordinate.id}']", visible: false).select_option
        sleep 1
        page.find('.widget-tasks-panel').click
        expect(page).to have_content(sub_task.name)
      end
    end
  end
end
