describe 'Client' do
  let(:admin) { create(:user, roles: 'admin') }
  let!(:user) { create(:user) }

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
    scenario 'Domain Score Statistic and Active Programs Statistic', js: true do
      page.find("#client-statistic").click
      wait_for_ajax
      expect(page).to have_css("#cis-domain-score[data-title='CSI Domain Scores']")
      expect(page).to have_css("#cis-domain-score[data-yaxis-title='Domain Scores']")
      expect(page).to have_css("#program-statistic[data-title='Active Programs']")
      expect(page).to have_css("#program-statistic[data-yaxis-title='Clients']")
    end
  end

  feature 'Show' do
    let!(:client){ create(:client, users: [user], state: 'accepted', current_address: '') }
    let!(:other_client){create(:client)}
    before do
      login_as(user)
      visit client_path(client)
    end

    feature 'country' do
      scenario 'Cambodia' do
        expect(page).to have_css('.address', text: 'Cambodia')
      end
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

    scenario 'government report invisible' do
      expect(page).not_to have_link(nil, href: client_path(client, format: 'pdf'))
    end

    scenario 'what3words link' do
      expect(page).to have_link(client.what3words, href: "https://map.what3words.com/#{client.what3words}")
    end

  end

  xfeature 'New', skip: '=== Capybara cannot find jQuery steps link ===' do
    let!(:province) { create(:province) }
    let!(:client)   { create(:client, given_name: 'Branderson', family_name: 'Anderson', local_given_name: 'Vin',
                             local_family_name: 'Kell', date_of_birth: '2017-05-01', birth_province: province,
                             province: province, village: 'Sabay', commune: 'Vealvong') }
    let!(:referral_source){ create(:referral_source) }
    before do
      login_as(user)
      visit new_client_path
    end
    scenario 'valid', js: true do
      find(".client_received_by_id select option[value='#{user.id}']", visible: false).select_option
      find(".client_users select option[value='#{user.id}']", visible: false).select_option
      fill_in 'client_initial_referral_date', with: Date.today
      find(".client_referral_source select option[value='#{referral_source.id}']", visible: false).select_option
      fill_in 'client_name_of_referee', with: FFaker::Name.name
      fill_in 'client_given_name', with: 'Kema'

      page.find('a[href="#next"]', visible: false).click

      expect(page).to have_content('Kema')
      expect(page).to have_content(date_format(Date.today))
    end

    scenario 'invalid as missing case workers', js: true do
      fill_in 'client_given_name', with: FFaker::Name.name
      click_button 'Save'
      wait_for_ajax
      expect(page).to have_content("can't be blank")
    end

    scenario 'warning', js: true do
      fill_in 'client_given_name', with: 'Branderjo'
      fill_in 'client_family_name', with: 'Anderjo'
      fill_in 'Given Name (kh)', with: 'Viny'
      fill_in 'Family Name (kh)', with: 'Kelly'
      fill_in 'Date of Birth', with: '2017-05-01'
      find(".client_users select option[value='#{user.id}']", visible: false).select_option
      find(".client_province select option[value='#{province.id}']", visible: false).select_option
      find(".client_birth_province_id select option[value='#{province.id}']", visible: false).select_option

      # click_button 'Save'
      wait_for_ajax
      expect(page).to have_content("The client you are registering has many attributes that match a client who is already registered at")
    end

    scenario 'government repor section invisible' do
      expect(page).not_to have_content('Government Form')
    end
  end

  feature 'Update', js: true, skip: '=== Capybara cannot find jQuery steps link ===' do
    let!(:client){ create(:client, users: [user]) }
    before do
      login_as(user)
      visit edit_client_path(client)
    end
    scenario 'valid', js: true do
      fill_in 'client_given_name', with: 'Allen'
      click_button 'Save'
      wait_for_ajax
      expect(page).to have_content('Allen')
    end

    xscenario 'invalid' do
      fill_in 'client_given_name', with: ''
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end

    scenario 'government repor section invisible' do
      expect(page).not_to have_content('Government Form')
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
      # expect(page).to have_link('Add to FC', href: new_client_case_path(client, case_type: 'FC'))
      # expect(page).to have_link('Add to KC', href: new_client_case_path(client, case_type: 'KC'))
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

      # scenario 'Foster Case Button' do
      #   expect(page).to have_link('Add to FC', href: new_client_case_path(blank_client, case_type: 'FC'))
      # end

      # scenario 'Kinship Case Button' do
      #   expect(page).to have_link('Add to KC', href: new_client_case_path(blank_client, case_type: 'KC'))
      # end

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

      # scenario 'Foster Case Button' do
      #   expect(page).to have_link('Add to FC', href: new_client_case_path(inactive_client, case_type: 'FC'))
      # end

      # scenario 'Kinship Case Button' do
      #   expect(page).to have_link('Add to KC', href: new_client_case_path(inactive_client, case_type: 'KC'))
      # end
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
    let!(:accepted_client2) { create(:client, state: 'accepted', users: [user]) }
    let!(:case) {create(:case, case_type: 'EC', client: accepted_client2, exited: false, start_date: 1.year.ago)}
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
      visit client_path(accepted_client2)
      time_in_care = accepted_client2.time_in_care
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

  feature 'Case notes, Assessments, Custom Field and Program Stream permission', js: true do
    let!(:client){ create(:client, users: [admin, user], state: 'accepted') }
    let!(:assessment) { create(:assessment, client: client) }
    let!(:case_note) { create(:case_note, assessment: assessment, client: client)}

    let!(:custom_field) { create(:custom_field) }
    let!(:custom_field_property) { create(:custom_field_property, custom_formable: client, custom_field: custom_field) }

    let!(:program_stream) { create(:program_stream) }
    let!(:client_enrollment) { create(:client_enrollment, client: client, program_stream: program_stream) }

    context 'can view and edit' do
      before do
        login_as(admin)
        visit client_path(client)
      end

      scenario 'case notes' do
        find("a[href='#{client_case_notes_path(client)}']").click
        expect("#{client_case_notes_path(client)}").to have_content(current_path)

        find("a[href='#{edit_client_case_note_path(client, case_note)}']").click
        expect("#{edit_client_case_note_path(client, case_note)}").to have_content(current_path)
      end

      scenario 'assessments' do
        find("a[href='#{client_assessments_path(client)}']").click
        find("a[href='#{client_assessment_path(client, assessment)}']").click
        expect("#{client_assessment_path(client, assessment)}").to have_content(current_path)

        find("a[href='#{edit_client_assessment_path(client, assessment)}']").click
        expect("#{edit_client_assessment_path(client, assessment)}").to have_content(current_path)
      end

      scenario 'custom fields' do
        find("a[href='#{client_custom_field_properties_path(client, custom_field_id: custom_field.id)}']", visible: false).trigger('click')
        expect(page).to have_content(custom_field.form_title)

        find("a[href='#{edit_client_custom_field_property_path(client, custom_field_property, custom_field_id: custom_field.id)}']").click
        expect("#{edit_client_custom_field_property_path(client, custom_field_property, custom_field_id: custom_field.id)}").to have_content(current_path)
      end

      scenario 'program streams' do
        find("a[href='#{client_client_enrolled_programs_path(client)}']").click
        expect("#{client_client_enrolled_programs_path(client)}").to have_content(current_path)

        visit "#{edit_client_client_enrolled_program_path(client, client_enrollment, program_stream_id: program_stream.id)}"
        expect("#{edit_client_client_enrolled_program_path(client, client_enrollment, program_stream_id: program_stream.id)}").to have_content(current_path)
      end
    end

    context 'cannot view and edit' do
      before do
        login_as(user)
        visit client_path(client)
      end

      scenario 'case notes' do
        user.permission.update(case_notes_readable: false, case_notes_editable: false)
        expect(page).not_to have_link("a[href='#{client_case_notes_path(client)}']")

        visit edit_client_case_note_path(client, case_note)
        expect(dashboards_path).to have_content(current_path)
      end

      scenario 'assessments' do
        user.permission.update(assessments_readable: false, assessments_editable: false)
        find("a[href='#{client_assessments_path(client)}']").click
        expect(page).not_to have_link("a[href='#{client_assessment_path(client, assessment)}']")

        visit edit_client_assessment_path(client, assessment)
        expect(dashboards_path).to have_content(current_path)
      end

      scenario 'custom fields' do
        user.custom_field_permissions.find_by(custom_field_id: custom_field.id).update(readable: false, editable: false)
        expect(page).not_to have_link("a[href='#{client_custom_field_properties_path(client, custom_field_id: custom_field.id)}']")

        visit edit_client_custom_field_property_path(client, custom_field_property, custom_field_id: custom_field.id)
        expect(dashboards_path).to have_content(current_path)
      end

      scenario 'program streams' do
        user.program_stream_permissions.find_by(program_stream_id: program_stream.id).update(readable: false, editable: false)
        find("a[href='#{client_client_enrolled_programs_path(client)}']").click
        expect(page).not_to have_content(program_stream.name)

        visit edit_client_client_enrolled_program_path(client, client_enrollment, program_stream_id: program_stream.id)
        expect(dashboards_path).to have_content(current_path)
      end
    end
  end
end
