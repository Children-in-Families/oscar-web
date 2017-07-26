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
  let!(:ec_client)       { create(:client, status: 'Active EC', users: [ec_caseworker]) }
  let!(:fc_client)       { create(:client, status: 'Active FC', users: [fc_caseworker]) }
  let!(:kc_client)       { create(:client, status: 'Active KC', users: [kc_caseworker]) }
  let!(:sub_client)      { create(:client, users: [subordinate]) }

  let!(:ec_task)   { create(:task, client: ec_client) }
  let!(:fc_task)   { create(:task, client: fc_client) }
  let!(:kc_task)   { create(:task, client: kc_client) }
  let!(:sub_task)  { create(:task, client: sub_client) }
  let!(:able_task) { create(:task, client: able_client) }

  let!(:overdue_task)    { create(:task, client: able_client, completion_date: Date.today - 6.month) }
  let!(:upcoming_task)   { create(:task, client: client2, completion_date: Date.today + 6.month) }

  feature 'User tasks' do
    feature 'Log in as Admin' do
      before do
        login_as(admin)
        visit clients_path
      end

      scenario 'list all users' do
        click_link 'View All Active Tasks'
        expect(page).to have_select 'user_id', with_options: ['mr admin', 'able manager', 'able caseworker', 'ec caseworker']
      end

      scenario 'list manager task', js: true do
        click_link 'View All Active Tasks'
        expect(page).to have_select 'user_id', with_options: ['mr admin', 'able manager', 'able caseworker', 'ec caseworker'], visible: false
        select2_select('able manager', '.select2-container')
        sleep 1
        panel = page.all(:css, '.panel').select { |p| p.all(:css, '.panel-heading').select { |pp| pp.text.include?('Upcoming Tasks') }.first }.first
        expect(panel).to have_content(upcoming_task.name)
      end

      scenario 'list caseworker task', js: true do
        click_link 'View All Active Tasks'
        expect(page).to have_select 'user_id', with_options: ['mr admin', 'able manager', 'able caseworker', 'ec caseworker'], visible: false
        select2_select('able caseworker', '.select2-container')
        sleep 1
        panel = page.all(:css, '.panel').select { |p| p.all(:css, '.panel-heading').select { |pp| pp.text.include?('Overdue Tasks') }.first }.first
        expect(panel).to have_content(overdue_task.name)
      end
    end

    feature 'Log in as Able Manager' do
      before do
        login_as(able_manager)
        visit clients_path
      end

      scenario 'list all able managers and case worker of able clients' do
        click_link 'View All Active Tasks'
        expect(page).to have_select 'user_id', with_options: ['able manager', 'able caseworker']
      end

      scenario 'list manager task', js: true do
        click_link 'View All Active Tasks'
        expect(page).to have_select 'user_id', with_options: ['able manager', 'able caseworker'], visible: false
        panel = page.all(:css, '.panel').select { |p| p.all(:css, '.panel-heading').select { |pp| pp.text.include?('Upcoming Tasks') }.first }.first
        expect(panel).to have_content(upcoming_task.name)
      end

      scenario 'list caseworker task', js: true do
        click_link 'View All Active Tasks'
        expect(page).to have_select 'user_id', with_options: ['able manager', 'able caseworker'], visible: false
        select2_select('able caseworker', '.select2-container')
        sleep 1
        panel = page.all(:css, '.panel').select { |p| p.all(:css, '.panel-heading').select { |pp| pp.text.include?('Overdue Tasks') }.first }.first
        expect(panel).to have_content(overdue_task.name)
      end

      scenario 'list able case worker task', js: true do
        click_link 'View All Active Tasks'
        select2_select('able caseworker', '.select2-container')
        sleep 1
        expect(page).to have_content(able_task.name)
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

    feature 'Log in as EC Manager' do
      before do
        login_as(ec_manager)
        visit clients_path
      end

      scenario 'list ec managers and case worker of Active EC clients' do
        click_link 'View All Active Tasks'
        expect(page).to have_select 'user_id', with_options: ['ec manager', 'ec caseworker']
      end

      scenario 'list ec case worker task', js: true do
        click_link 'View All Active Tasks'
        select2_select('ec caseworker', '.select2-container')
        sleep 1
        expect(page).to have_content(ec_task.name)
      end
    end

    feature 'Log in as FC Manager' do
      before do
        login_as(fc_manager)
        visit clients_path
      end

      scenario 'list fc managers and case worker of Active FC clients' do
        click_link 'View All Active Tasks'
        expect(page).to have_select 'user_id', with_options: ['fc manager', 'fc caseworker']
      end

      scenario 'list fc case worker task', js: true do
        click_link 'View All Active Tasks'
        select2_select('fc caseworker', '.select2-container')
        sleep 1
        expect(page).to have_content(fc_task.name)
      end
    end

    feature 'Log in as KC Manager' do
      before do
        login_as(kc_manager)
        visit clients_path
      end

      scenario 'list kc managers and case worker of Active KC clients' do
        click_link 'View All Active Tasks'
        expect(page).to have_select 'user_id', with_options: ['kc manager', 'kc caseworker']
      end

      scenario 'list kc case worker task', js: true do
        click_link 'View All Active Tasks'
        select2_select('kc caseworker', '.select2-container')
        sleep 1
        expect(page).to have_content(kc_task.name)
      end
    end

    feature 'Log in as Manager' do
      before do
        login_as(manager)
        visit clients_path
      end

      scenario 'list managers and their subordinates' do
        click_link 'View All Active Tasks'
        expect(page).to have_select 'user_id', with_options: ['manager', 'subordinate']
      end

      scenario 'list subordinate task', js: true do
        click_link 'View All Active Tasks'
        select2_select('subordinate', '.select2-container')
        sleep 1
        expect(page).to have_content(sub_task.name)
      end
    end
  end
end
