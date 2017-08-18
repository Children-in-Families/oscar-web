describe 'Client' do
  let(:admin) { create(:user, roles: 'admin') }
  let(:user) { create(:user) }

  feature 'List' do
    let!(:client){create(:client, users: [user])}
    let!(:other_client) {create(:client)}
    let!(:domain) { create(:domain, name: "1A") }

    before do
      login_as(user)
      visit clients_path
    end

    scenario 'new link' do
      expect(page).to have_link('Add New Client', href: new_client_path)
    end

    scenario 'name' do
      expect(page).to have_content(client.name)
    end

    scenario 'edit link' do
      expect(page).to have_link(nil, href: edit_client_path(client))
    end

    scenario 'delete link' do
      expect(page).to have_css("a[href='#{client_path(client)}'][data-method='delete']")
    end

    scenario 'no other name' do
      expect(page).not_to have_content(other_client.name)
    end

    scenario 'admin' do
      login_as(admin)
      visit clients_path
      expect(page).to have_content(client.name)
      expect(page).to have_content(other_client.name)
    end
  end

  feature 'Reports' do
    before do
      login_as(admin)
      visit clients_path
    end
    scenario 'Domain Score Statistic and Case Type Statistic', js: true do
      page.find("#client-statistic").click
      wait_for_ajax
      expect(page).to have_css("#cis-domain-score[data-title='CSI Domain Scores']")
      expect(page).to have_css("#cis-domain-score[data-yaxis-title='Domain Scores']")
      expect(page).to have_css("#case-statistic[data-title='Case Statistics']")
      expect(page).to have_css("#case-statistic[data-yaxis-title='Client Amounts']")
    end
  end

  feature 'Show' do
    let!(:client){ create(:client, users: [user], state: 'accepted') }
    let!(:other_client){create(:client)}
    before do
      login_as(user)
      visit client_path(client)
    end
    scenario 'information' do
      expect(page).to have_content(client.name)
      expect(page).to have_content(client.gender.capitalize)
      expect(page).to have_content(client.date_of_birth.strftime('%B %d, %Y'))
    end

    scenario 'tasks link' do
      expect(page).to have_link('Tasks', href: client_tasks_path(client))
    end

    scenario 'assesstments link' do
      expect(page).to have_link('Assessments', href: client_assessments_path(client))
    end

    scenario 'case notes link' do
      expect(page).to have_link('Case Note', href: client_case_notes_path(client))
    end

    scenario 'edit link' do
      expect(page).to have_link(nil, href: edit_client_path(client))
    end

    scenario 'delete link' do
      expect(page).to have_css("a[href='#{client_path(client)}'][data-method='delete']")
    end
  end

  feature 'New' do
    let!(:province) { create(:province) }
    let!(:client)   { create(:client, given_name: 'Branderson', family_name: 'Anderson', local_given_name: 'Vin',
                             local_family_name: 'Kell', date_of_birth: '2017-05-01', birth_province: province,
                             province: province, village: 'Sabay', commune: 'Vealvong') }
    before do
      login_as(user)
      visit new_client_path
    end
    scenario 'valid', js: true do
      fill_in 'Given Name', with: 'Kema'
      find(".client_users select option[value='#{user.id}']", visible: false).select_option
      click_button 'Save'
      wait_for_ajax
      expect(page).to have_content('Kema')
    end

    scenario 'invalid as missing case workers', js: true do
      fill_in 'Given Name', with: FFaker::Name.name
      click_button 'Save'
      wait_for_ajax
      expect(page).to have_content("can't be blank")
    end

    scenario 'warning', js: true do
      fill_in 'Given Name', with: 'Branderjo'
      fill_in 'Family Name', with: 'Anderjo'
      fill_in 'Given Name (Local)', with: 'Viny'
      fill_in 'Family Name (Local)', with: 'Kelly'
      fill_in 'Date of Birth', with: '2017-05-01'
      find(".client_users select option[value='#{user.id}']", visible: false).select_option

      select2_select province.name, '.client_province'
      select2_select province.name, '.client_birth_province_id'

      fill_in 'Village', with: 'Sabay'
      fill_in 'Commune', with: 'Vealvong'

      click_button 'Save'
      wait_for_ajax

      expect(page).to have_content("The client you are registering has many attributes that match a client who is already registered at")
    end
  end

  feature 'Update', js: true do
    let!(:client){ create(:client, users: [user]) }
    before do
      login_as(user)
      visit edit_client_path(client)
    end
    scenario 'valid', js: true do
      fill_in 'Given Name', with: 'Allen'
      click_button 'Save'
      wait_for_ajax
      expect(page).to have_content('Allen')
    end

    xscenario 'invalid' do
      fill_in 'Given Name', with: ''
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Delete', js: true do
    let!(:client){ create(:client, users: [user]) }
    before do
      login_as(user)
      visit clients_path
    end
    scenario 'successfully' do
      first("a[data-method='delete'][href='#{client_path(client.reload)}']").click
      sleep 1
      expect(page).to have_content('Client has been successfully deleted')
    end
  end

  feature 'Accept' do
    let!(:client){create(:client, users: [user])}
    before do
      login_as(user)
      visit client_path(client)
      click_button 'Accept'
    end
    scenario 'has new case note link' do
      expect(page).to have_link('Add to EC', href: new_client_case_path(client, case_type: 'EC'))
      expect(page).to have_link('Add to FC', href: new_client_case_path(client, case_type: 'FC'))
      expect(page).to have_link('Add to KC', href: new_client_case_path(client, case_type: 'KC'))
    end
  end

  feature 'Reject' do
    let!(:client){create(:client, users: [user])}
    before do
      login_as(user)
      visit client_path(client)
      click_button 'Reject'

      fill_in 'Note', with: 'Rejected'
      find("input[type='submit'][value='Reject']").click
    end
    scenario 'successfully', js: true do
      wait_for_ajax
      expect(page).to have_content('Rejected')
    end
  end

  feature 'Accept and Reject' do
    let!(:non_status_client){ create(:client, state: '', users: [user]) }
    let!(:rejected_client){ create(:client, state: 'rejected', rejected_note: 'Something', users: [user]) }
    before do
      login_as(user)
    end
    scenario 'both button' do
      visit client_path(non_status_client)
      expect(page).to have_css("input[type='submit'][value='Accept']")
      expect(page).to have_css("input[type='submit'][value='Reject']")
    end

    scenario 'no rejected button' do
      visit client_path(rejected_client)
      expect(page).not_to have_css("input[type='submit'][value='Reject']")
    end
  end

  feature 'List Case' do
    let!(:accepted_client){ create(:client, state: 'accepted', users: [user]) }

    feature 'All Case' do
      let!(:emergency_case){ create(:case, case_type: 'EC', client: accepted_client) }
      let!(:foster_case){ create(:case, case_type: 'FC', client: accepted_client) }
      let!(:kinship_case){ create(:case, case_type: 'KC', client: accepted_client) }

      before do
        login_as(user)
        visit client_path(accepted_client)
      end

      scenario 'All Panel' do
        click_button (I18n.t('clients.show.add_client_to_case'))
        expect(page).to have_content('Emergency Care')
        expect(page).to have_content('Foster Care')
        expect(page).to have_content('Kinship Care')
      end

      scenario 'Emergency Info' do

        expect(page).to have_content(emergency_case.start_date.strftime('%B %d, %Y'))
        expect(page).to have_content(emergency_case.carer_names)
        expect(page).to have_content(emergency_case.carer_phone_number)
      end

      scenario 'Foster Info' do
        expect(page).to have_content(foster_case.carer_address)
        expect(page).to have_content(foster_case.province.name)
        expect(page).to have_content(ActionController::Base.helpers.number_to_currency(foster_case.support_amount))
      end

      scenario 'Kinship Info' do

        expect(page).to have_content(foster_case.support_note)
        expect(page).to have_content(foster_case.partner.name)
      end

    end

    feature 'Emergency Case' do
      let!(:emergency_case){ create(:case, case_type: 'EC', client: accepted_client) }

      before do
        login_as(user)
        visit client_path(accepted_client)
      end

      scenario 'Emergency Case panel' do
        expect(page).to have_content('Emergency Care')
      end

      scenario 'No Foster and Kinship case panel' do
        expect(page).not_to have_content('Kinship Care')
        expect(page).not_to have_content('Foster Care')
      end
    end
    feature 'Foster Case' do
      let!(:foster_case){ create(:case, case_type: 'FC', client: accepted_client) }

      before do
        login_as(user)
        visit client_path(accepted_client)
      end

      scenario 'Foster Case panel' do
        expect(page).to have_content('Foster Care')
      end

      scenario 'No Kinship and Emergency case panel' do
        expect(page).not_to have_content('Emergency Care')
        expect(page).not_to have_content('Kinship Care')
      end
    end
    feature 'Kinship Case' do
      let!(:kinship_case){ create(:case, case_type: 'KC', client: accepted_client) }

      before do
        login_as(user)
        visit client_path(accepted_client)
      end

      scenario 'Kinship Case panel' do
        expect(page).to have_content('Kinship Care')
      end

      scenario 'No Foster and Emergency case panel' do
        expect(page).not_to have_content('Foster Care')
        expect(page).not_to have_content('Emergency Care')
      end
    end
  end

  feature 'Case Button' do
    feature 'Blank Client' do
      let!(:blank_client){ create(:client, state: 'accepted', users: [user]) }

      before do
        login_as(user)
        visit client_path(blank_client)
      end

      scenario 'Emergency Case Button' do
        expect(page).to have_link('Add to EC', href: new_client_case_path(blank_client, case_type: 'EC'))
      end

      scenario 'Foster Case Button' do
        expect(page).to have_link('Add to FC', href: new_client_case_path(blank_client, case_type: 'FC'))
      end

      scenario 'Kinship Case Button' do
        expect(page).to have_link('Add to KC', href: new_client_case_path(blank_client, case_type: 'KC'))
      end

      scenario 'Exit NGO Button' do
        expect(page).to have_content('Exit From NGO')
      end
    end

    feature 'Emergency Active Client' do
      let!(:ec_client){ create(:client, state: 'accepted', users: [user]) }
      let!(:case){ create(:case, case_type: 'EC', client: ec_client, exited: false) }

      before do
        login_as(user)
        visit client_path(ec_client)
      end

      scenario 'Emergency Case Button' do
        expect(page).not_to have_link('Add to EC', href: new_client_case_path(ec_client, case_type: 'EC'))
      end

      scenario 'Foster Case Button' do
        expect(page).not_to have_link('Add to FC', href: new_client_case_path(ec_client, case_type: 'FC'))
      end

      scenario 'Kinship Case Button' do
        expect(page).not_to have_link('Add to KC', href: new_client_case_path(ec_client, case_type: 'KC'))
      end

      scenario 'Exit From EC' do
        exit_case_button = find('.exit-case-warning')
        expect(exit_case_button).to have_content('Exit From EC')
      end
    end

    feature 'Active Foster Client' do
      let!(:fc_client){ create(:client, state: 'accepted', users: [user]) }
      let!(:case){ create(:case, case_type: 'FC', client: fc_client, exited: false) }

      before do
        login_as(user)
        visit client_path(fc_client)
      end
      scenario 'FC' do
        exit_case_button = find('.exit-case-warning')
        expect(exit_case_button).to have_content('Exit From FC')
      end
    end

    feature 'Active Kinship Client' do
      let!(:kc_client){ create(:client, state: 'accepted', users: [user]) }
      let!(:case){ create(:case, case_type: 'KC', client: kc_client, exited: false) }

      before do
        login_as(user)
        visit client_path(kc_client)
      end
      scenario 'KC' do
        exit_case_button = find('.exit-case-warning')
        expect(exit_case_button).to have_content('Exit From KC')
      end
    end

    feature 'Not Emergency Active Client' do
      let!(:active_client){ create(:client, state: 'accepted', users: [user]) }
      let!(:case){ create(:case, case_type: ['FC', 'KC'].sample, client: active_client, exited: false) }

      before do
        login_as(user)
        visit client_path(active_client)
      end

      scenario 'Emergency Case Button' do
        expect(page).not_to have_link('Add to EC', href: new_client_case_path(active_client, case_type: 'EC'))
      end

      scenario 'Foster Case Button' do
        expect(page).not_to have_link('Add to FC', href: new_client_case_path(active_client, case_type: 'FC'))
      end

      scenario 'Kinship Case Button' do
        expect(page).not_to have_link('Add to KC', href: new_client_case_path(active_client, case_type: 'KC'))
      end
    end
    feature 'Inactive Client' do
      let!(:inactive_client){ create(:client, state: 'accepted', users: [user]) }
      let!(:case){ create(:case, :inactive, case_type: ['EC', 'FC', 'KC'].sample, client: inactive_client) }

      before do
        login_as(user)
        visit client_path(inactive_client)
      end

      scenario 'Emergency Case Button' do
        expect(page).to have_link('Add to EC', href: new_client_case_path(inactive_client, case_type: 'EC'))
      end

      scenario 'Foster Case Button' do
        expect(page).to have_link('Add to FC', href: new_client_case_path(inactive_client, case_type: 'FC'))
      end
      scenario 'Kinship Case Button' do
        expect(page).to have_link('Add to KC', href: new_client_case_path(inactive_client, case_type: 'KC'))
      end
    end
  end

  feature 'Qualify Report' do
    let!(:accepted_client){ create(:client, state: 'accepted', users: [user]) }
    let!(:client_case){ create(:case, case_type: 'KC', client: accepted_client) }
    let!(:quarterly_report){ create(:quarterly_report, case: client_case) }
    before do
      login_as(admin)
      visit client_path(accepted_client)
    end
    scenario 'view link' do
      expect(page).to have_link('Legacy Quarterly Reports', href: client_case_quarterly_reports_path(accepted_client, client_case))
    end
  end

  feature 'Exit Case' do
    let(:accepted_client) { create(:client, state: 'accepted', users: [user]) }
    let!(:client_case) { create(:case, case_type: ['EC', 'FC', 'KC'].sample, client: accepted_client) }

    before do
      login_as(user)
      visit client_path(accepted_client)
    end
    scenario 'Exit Button' do
      button = find("button[data-target='#exit-from-case']")
      expect(button).to have_content('Remove Client from Program')
    end
    scenario 'Note', js: true do
      page.find("button[data-target='#exit-from-case']").click
      page.find(:css, '#exit-from-case')
      within '#exit-from-case' do
        fill_in 'Exit Date', with: '2017-07-07'
        fill_in 'Exit Note', with: FFaker::Lorem.paragraph
      end
      page.find("input[type='submit'][value='Exit']").click
      expect(page).to have_content('Referred')
    end
  end

  feature 'Time in care' do
    let!(:accepted_client) { create(:client, state: 'accepted', users: [user]) }
    before do
      login_as(user)
    end
    scenario 'without any cases' do
      visit client_path(accepted_client)
      time_in_care = accepted_client.time_in_care
      expect(time_in_care).to be_nil
      expect(page).to have_content(time_in_care)
    end

    scenario 'with case' do
      Case.create(case_type: 'EC', client: accepted_client, exited: false, start_date: 1.year.ago)

      visit client_path(accepted_client)
      time_in_care = accepted_client.time_in_care
      expect(page).to have_content(time_in_care)
    end
  end

  feature 'Enable Edit Emergency Care' do
    let!(:accepted_client) { create(:client, state: 'accepted', users: [user]) }
    let!(:ec_case){ create(:case, case_type: 'EC', client: accepted_client) }
    let!(:kc_manager){ create(:user, roles: 'kc manager') }
    feature 'of active EC and FC/KC client' do
      feature 'login as case worker' do
        let!(:fc_case){ create(:case, case_type: 'FC', client: accepted_client) }
        before do
          login_as(kc_manager)
          visit client_path(accepted_client)
        end
        it { expect(page).not_to have_link(nil, href: edit_client_case_path(ec_case.client, ec_case)) }
      end

      feature 'login as admin' do
        let!(:kc_case){ create(:case, case_type: 'KC', client: accepted_client) }
        before do
          login_as(admin)
          visit client_path(accepted_client)
        end
        it { expect(page).to have_link(nil, href: edit_client_case_path(ec_case.client, ec_case)) }
      end
    end
  end
end
