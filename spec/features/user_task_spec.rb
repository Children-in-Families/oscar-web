describe Task do
  let!(:admin)           { create(:user, roles: 'admin', first_name: 'mr', last_name: 'admin') }
  let!(:manager)         { create(:user, :manager, first_name: 'manager') }
  let!(:able_caseworker) { create(:user, first_name: 'able', last_name: 'caseworker') }
  let!(:subordinate)     { create(:user, :case_worker, first_name: 'subordinate', manager_id: manager.id) }

  let!(:able_client)     { create(:client, :accepted, users: [able_caseworker]) }
  let!(:client2)         { create(:client, :accepted, users: [manager]) }
  let!(:sub_client)      { create(:client, :accepted, users: [subordinate]) }

  let!(:sub_task)  { create(:task, client: sub_client, user: subordinate) }
  let!(:overdue_task)    { create(:task, user: able_caseworker, client: able_client, completion_date: Date.today - 6.month) }
  let!(:upcoming_task)   { create(:task, client: client2, user: manager, completion_date: Date.tomorrow) }

  feature 'User tasks' do
    feature 'Log in as Admin' do
      before do
        login_as(admin)
        visit dashboards_path
      end

      scenario 'list all users' do
        expect(page).to have_select 'user_id', with_options: ['mr admin', 'manager', 'able caseworker']
      end

      scenario 'list manager task', js: true do
        page.find('.widget-tasks-panel').click
        expect(page).to have_select 'user_id', with_options: ['mr admin', 'manager', 'able caseworker'], visible: false
        find("select#user_id option[value='#{manager.id}']", visible: false).select_option
        click_button('Apply')
        sleep 1

        expect(page).to have_content(upcoming_task.name)
        expect(page).to have_link(client2.name, href: client_path(client2))
      end

      scenario 'list caseworker task', js: true do
        page.find('.widget-tasks-panel').click
        expect(page).to have_select 'user_id', with_options: ['mr admin', 'able caseworker'], visible: false
        find("select#user_id option[value='#{able_caseworker.id}']", visible: false).select_option
        click_button('Apply')
        sleep 1

        expect(page).to have_content(overdue_task.name)
        expect(page).to have_link(able_client.name, href: client_path(able_client))
      end
    end

    feature 'Log in as Caseworker' do
      before do
        login_as(able_caseworker)
        visit dashboards_path
      end

      scenario 'display only caseworker task', js: true do
        page.find('.widget-tasks-panel').click

        expect(page).to have_content(overdue_task.name)
      end

      scenario 'unable to use filter by user' do
        expect(page).not_to have_select 'user_id'
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

      scenario 'list subordinate task', js: true do
        page.find('.widget-tasks-panel').click
        find("select#user_id option[value='#{subordinate.id}']", visible: false).select_option
        click_button('Apply')
        sleep 1

        expect(page).to have_content(sub_task.name)
      end
    end
  end
end
