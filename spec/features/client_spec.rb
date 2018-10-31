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
      first('.datagrid-actions').click_button 'Search'
    end

    scenario 'new link' do
      expect(page).to have_link('Add New Client', href: new_client_path)
    end

    scenario 'name' do
      expect(page).to have_content(client.given_name)
    end

    scenario 'edit link' do
      expect(page).to have_link(nil, href: edit_client_path(client))
    end

    scenario 'delete link' do
      expect(page).to have_css("a[href='#{client_path(client)}'][data-method='delete']")
    end

    scenario 'no other name' do
      expect(page).not_to have_content(other_client.given_name)
    end

    scenario 'admin' do
      login_as(admin)
      visit clients_path
      first('.datagrid-actions').click_button 'Search'
      expect(page).to have_content(client.given_name)
      expect(page).to have_content(other_client.given_name)
    end
  end

  feature 'Reports' do
    before do
      login_as(admin)
      visit clients_path
      find('.client-search').click
      sleep 1
      first('.datagrid-actions').click_button 'Search'
      sleep 1
    end
    scenario 'Domain Score Statistic and Active Programs Statistic', js: true do
      page.find("#client-statistic").click
      # wait_for_ajax
      expect(page).to have_css("#cis-domain-score[data-title='CSI Domain Scores']")
      expect(page).to have_css("#cis-domain-score[data-yaxis-title='Domain Scores']")
      expect(page).to have_css("#program-statistic[data-title='Active Programs']")
      expect(page).to have_css("#program-statistic[data-yaxis-title='Clients']")
    end
  end

  feature 'Show' do
    let!(:client){ create(:client, :accepted, current_address: '', profile: UploadedFile.new(File.open(File.join(Rails.root, '/spec/supports/image-placeholder.png')))) }
    let!(:setting){ Setting.first }
    let!(:program_stream) { create(:program_stream) }

    before do
      PaperTrail::Version.where(event: 'create', item_type: 'Client', item_id: client.id).update_all(whodunnit: admin.id)
      login_as(admin)
      visit client_path(client)
    end

    feature 'Time in care' do
      let!(:once_enrollment) { create(:client_enrollment, enrollment_date: '2018-01-01', program_stream: program_stream, client: client) }
      let!(:client_exit) { create(:leave_program, exit_date: '2019-02-01', program_stream: program_stream, client_enrollment: once_enrollment) }

      let!(:client_2) { create(:client, :accepted, current_address: '') }
      let!(:first_client_2_enrollment) { create(:client_enrollment, enrollment_date: '2018-01-01', program_stream: program_stream, client: client_2) }
      let!(:first_client_2_exit) { create(:leave_program, exit_date: '2019-02-01', program_stream: program_stream, client_enrollment: first_client_2_enrollment) }
      let!(:second_client_2_enrollment) { create(:client_enrollment, enrollment_date: '2019-02-01', program_stream: program_stream, client: client_2) }
      let!(:second_client_2_exit) { create(:leave_program, exit_date: '2019-05-01', program_stream: program_stream, client_enrollment: second_client_2_enrollment) }

      let!(:client_3) { create(:client, :accepted, current_address: '') }
      let!(:first_client_3_enrollment) { create(:client_enrollment, enrollment_date: '2018-01-01', program_stream: program_stream, client: client_3) }
      let!(:first_client_3_exit) { create(:leave_program, exit_date: '2019-02-01', program_stream: program_stream, client_enrollment: first_client_3_enrollment) }
      let!(:second_client_3_enrollment) { create(:client_enrollment, enrollment_date: '2019-02-01', program_stream: program_stream, client: client_3) }
      let!(:second_client_3_exit) { create(:leave_program, exit_date: '2019-05-01', program_stream: program_stream, client_enrollment: second_client_3_enrollment) }
      let!(:third_client_3_enrollment) { create(:client_enrollment, enrollment_date: '2019-06-01', program_stream: program_stream, client: client_3) }
      let!(:third_client_3_exit) { create(:leave_program, exit_date: '2019-07-01', program_stream: program_stream, client_enrollment: third_client_3_enrollment) }

      scenario 'profile photo' do
        visit client_path(client)
        expect(page.find('#client_photo')['alt']).to match(/image-placeholder.png/)
      end

      scenario 'once enrollment' do
        visit client_path(client)
        expect(page).to have_content('1 year 1 month')
      end

      scenario 'continuous enrollment' do
        visit client_path(client_2)
        expect(page).to have_content('1 year 4 month')
      end

      scenario 'enrollment with one month delay' do
        visit client_path(client_3)
        expect(page).to have_content('1 year 5 month')
      end
    end

    feature 'country' do
      scenario 'Cambodia' do
        expect(page).to have_css('.address', text: 'Cambodia')
      end
    end

    scenario 'alias id' do
      expect(page).to have_content(client.slug)
      # FTS instance expects to see client code instead of slug
    end

    scenario 'Created by .. on ..' do
      user = whodunnit_client(client.id)
      date = client.created_at.strftime('%d %B %Y')
      expect(page).to have_content("Created by #{user} on #{date}")
    end

    scenario 'information' do
      expect(page).to have_content(client.given_name)
      expect(page).to have_content(client.gender.capitalize)
      expect(page).to have_content(client.date_of_birth.strftime('%d %B %Y'))
    end

    scenario 'tasks link' do
      expect(page).to have_link('Tasks', href: client_tasks_path(client))
    end

    feature 'assesstments link' do
      scenario 'enable assessment tool' do
        expect(page).to have_link('Assessments', href: client_assessments_path(client))
      end

      scenario 'disable assessment tool' do
        setting.update(disable_assessment: true)
        visit current_path
        expect(page).not_to have_link('Assessments', href: client_assessments_path(client))
      end
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

    feature 'No create' do
      let!(:client){ create(:client, :accepted) }

      let!(:task){ create(:task, :incomplete, :overdue, client: client) }
      let!(:assessment){ create(:assessment, client: client) }
      let!(:case_note){ create(:case_note, client: client, assessment: assessment) }
      let!(:ec_case){ create(:case, :emergency, :inactive, client: client) }

      let!(:custom_field){ create(:custom_field) }
      let!(:custom_field_property){ create(:custom_field_property, custom_formable: client, custom_field: custom_field) }

      let!(:program_stream){create(:program_stream)}
      let!(:tracking){create(:tracking, program_stream: program_stream)}
      let!(:client_enrollment){create(:client_enrollment, client: client, program_stream: program_stream)}
      let!(:client_enrollment_tracking){create(:client_enrollment_tracking, client_enrollment: client_enrollment, tracking: tracking)}
      let!(:leave_program){create(:leave_program, client_enrollment: client_enrollment, program_stream: program_stream)}

      before do
        client.update(status: 'Exited', exit_date: Date.today, exit_note: 'Test', exit_circumstance: 'Exit Client')
        login_as admin
        visit client_path(client)
      end

      scenario 'Add Client to Case' do
        expect(page).to have_css('#add-client-to-case')
      end

      scenario 'Tasks' do
        visit client_tasks_path(client)
        expect(page).to have_link(nil, href: edit_client_task_path(client, task))
        expect(page).to have_css("a[href='#{client_task_path(client, task)}'][data-method='delete']")
      end

      scenario 'Assessments' do
        visit client_assessments_path(client)
        expect(page).to have_link('View Report', href: client_assessment_path(client, assessment))
        expect(page).not_to have_link('Add New Assessment', href: new_client_assessment_path(client))

        visit client_assessment_path(client, assessment)
        expect(page).to have_link(nil, href: edit_client_assessment_path(client, assessment))
      end

      scenario 'Case Notes' do
        visit client_case_notes_path(client)
        expect(page).not_to have_link('New case note', href: new_client_case_note_path(client))
        expect(page).to have_link(nil, href: edit_client_case_note_path(client, case_note))
      end

      scenario 'Case history' do
        visit client_cases_path(client)
        expect(page).to have_link(nil, href: edit_client_case_path(client, ec_case))
      end

      scenario 'Additional Forms' do
        visit client_custom_field_properties_path(client, custom_field_id: custom_field.id)
        expect(page).not_to have_link("Add New #{custom_field.form_title}", href: new_client_custom_field_property_path(client, custom_field_id: custom_field))
        expect(page).to have_link(nil, href: edit_client_custom_field_property_path(client, custom_field_property, custom_field_id: custom_field))
        expect(page).to have_css("a[href='#{client_custom_field_property_path(client, custom_field_property, custom_field_id: custom_field)}'][data-method='delete']")
      end

      scenario 'Program Streams' do
        visit client_client_enrollments_path(client)
        expect(page).not_to have_link('Enroll', href: client_client_enrollment_path(client, client_enrollment, program_stream_id: program_stream))

        visit client_client_enrollment_path(client, client_enrollment, program_stream_id: program_stream)
        expect(page).to have_link(nil, href: edit_client_client_enrollment_path(client, client_enrollment, program_stream_id: program_stream))
        expect(page).to have_css("a[href='#{client_client_enrollment_path(client, client_enrollment, program_stream_id: program_stream)}'][data-method='delete']")

        visit client_client_enrollment_client_enrollment_tracking_path(client, client_enrollment, client_enrollment_tracking)
        expect(page).not_to have_link(nil, href: edit_client_client_enrollment_client_enrollment_tracking_path(client, client_enrollment, client_enrollment_tracking, tracking_id: tracking))

        visit client_client_enrollment_leave_program_path(client, client_enrollment, leave_program)
        expect(page).to have_link(nil, href: edit_client_client_enrollment_leave_program_path(client, client_enrollment, leave_program, program_stream_id: program_stream))
      end
    end

    feature 'Specific point of Referral Data Permission' do
      let!(:quantitative_type){ create(:quantitative_type) }
      let!(:second_quantitative_type){ create(:quantitative_type) }
      let!(:quantitative_case){ create(:quantitative_case, quantitative_type: quantitative_type) }
      let!(:second_quantitative_case){ create(:quantitative_case, quantitative_type: second_quantitative_type) }
      let!(:client){ create(:client, :accepted, quantitative_case_ids: [quantitative_case.id, second_quantitative_case.id], users: [user]) }
      let!(:quantitative_type_permission){ create(:quantitative_type_permission, quantitative_type_id: quantitative_type.id, user_id: user.id, readable: false) }
      let!(:quantitative_type_readable_permission){ create(:quantitative_type_permission, quantitative_type_id: second_quantitative_type.id, user_id: user.id) }

      before do
        login_as(user)
        visit client_path(client)
      end

      scenario 'Can Read Referral Data' do
        expect(page).to have_content(second_quantitative_type.name)
      end

      scenario 'Cannot Read Referral Data' do
        expect(page).not_to have_content(quantitative_type.name)
      end
    end
  end

  feature 'New' do
    let!(:province) { create(:province) }
    let!(:client)   { create(:client, given_name: 'Branderson', family_name: 'Anderson', local_given_name: 'Vin',
                             local_family_name: 'Kell', date_of_birth: '2017-05-01', birth_province: province,
                             province: province) }
    let!(:referral_source){ create(:referral_source) }
    before do
      login_as(admin)
      visit new_client_path
    end

    scenario 'valid', js: true do
      find(".client_received_by_id select option[value='#{user.id}']", visible: false).select_option
      find(".client_users select option[value='#{user.id}']", visible: false).select_option
      fill_in 'client_initial_referral_date', with: Date.today
      find(".client_referral_source select option[value='#{referral_source.id}']", visible: false).select_option
      fill_in 'client_name_of_referee', with: 'Thida'
      fill_in 'client_given_name', with: 'Kema'
      find(".client_gender select option[value='male']", visible: false).select_option
      find('#client_profile', visible: false).set('spec/supports/image-placeholder.png')

      find('#steps-uid-0-t-3').click
      page.find('a[href="#finish"]', visible: false).click

      expect(page).to have_content('Kema')
      expect(page).to have_content('Thida')
      expect(page.find('#client_photo')['alt']).to match(/image-placeholder.png/)
    end

    scenario 'invalid as missing case workers', js: true do
      fill_in 'client_given_name', with: FFaker::Name.name
      find('#steps-uid-0-t-3').click
      wait_for_ajax
      expect(page).to have_content("can't be blank")
    end

    scenario 'warning', js: true do
      find(".client_received_by_id select option[value='#{user.id}']", visible: false).select_option
      find(".client_users select option[value='#{user.id}']", visible: false).select_option
      find(".client_referral_source select option[value='#{referral_source.id}']", visible: false).select_option
      fill_in 'client_name_of_referee', with: FFaker::Name.name
      fill_in 'client_initial_referral_date', with: Date.today

      fill_in 'client_given_name', with: 'Branderjo'
      fill_in 'client_family_name', with: 'Anderjo'
      fill_in 'client_local_given_name', with: 'Viny'
      fill_in 'client_local_family_name', with: 'Kelly'
      fill_in 'Date of Birth', with: '2017-05-01'

      find('#steps-uid-0-t-1').click
      find(".client_province select option[value='#{province.id}']", visible: false).select_option
      find('#steps-uid-0-t-3').click
      page.find('a[href="#finish"]', visible: false).click
      wait_for_ajax
      expect(page).to have_content("The client you are registering has many attributes that match a client who is already registered at")
    end

    scenario 'government report section invisible' do
      expect(page).not_to have_content('Government Form')
    end
  end

  feature 'Update', js: true do
    let!(:client){ create(:client, users: [user]) }
    let!(:task){ create(:task, client_id: client.id, user_id: user.id) }
    before do
      login_as(admin)
      visit edit_client_path(client)
    end

    scenario 'valid', js: true do
      fill_in 'client_name_of_referee', with: 'Allen'
      find('#client_profile', visible: false).set('spec/supports/image-placeholder.png')
      find('.save-edit-client').trigger('click')
      wait_for_ajax
      expect(page).to have_content('Allen')
      expect(page.find('#client_photo')['alt']).to match(/image-placeholder.png/)
    end

    scenario 'invalid' do
      fill_in 'client_name_of_referee', with: ''
      find('.save-edit-client').trigger('click')
      expect(page).to have_content("can't be blank")
    end

    scenario 'locked user who has incomplete tasks' do
      expect(page).to have_selector(:css, "option[locked='locked']", text: user.name, count: 1, visible: false)
    end
  end

  feature 'edit client', js: true do
    let!(:client){ create(:client, users: [user]) }
    before do
      login_as(admin)
      visit edit_client_path(client)
    end

    scenario 'click tab Getting Started', js: true do
      click_link 'Getting Started'
      page.has_field?('client[initial_referral_date]')
    end

    scenario 'click tab Living Details', js: true do
      click_link 'Living Details'
      page.has_field?('client[live_with]')
    end

    scenario 'click tab Other Details', js: true do
      click_link 'Other Details'
      page.has_field?('client[agency_ids][]')
    end

    scenario 'click tab Specific Point-of-Referral Data', js: true do
      click_link 'Specific Point-of-Referral Data'
      page.has_field?('client[quantitative_case_ids][]')
    end

  end

  feature 'Delete' do
    let!(:client){ create(:client, users: [user]) }
    before do
      login_as(admin)
      visit clients_path
      first('.datagrid-actions').click_button 'Search'
    end
    scenario 'successful' do
      first("a[data-method='delete'][href='#{client_path(client.reload)}']").click
      expect(Client.all.ids).not_to include(client.id)
    end
  end

  feature 'Case Button' do
    feature 'Blank Client' do
      let!(:blank_client){ create(:client, :accepted) }

      before do
        login_as(admin)
        visit client_path(blank_client)
      end

      scenario 'Exit NGO Button' do
        expect(page).to have_content('Exit Client From NGO')
      end
    end
  end

  feature 'Quarterly Report' do
    let!(:accepted_client){ create(:client, :accepted) }
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

  feature 'Exit Case', js: true do
    let!(:accepted_client) { create(:client, :accepted) }
    let!(:client_case) { create(:case, :emergency, client: accepted_client) }

    before do
      login_as(admin)
      visit client_path(accepted_client)
    end

    context 'before' do
      it "client's status is Active" do
        expect(accepted_client.reload.status).to eq('Active')
      end
    end

    context 'after' do
      it "client's status is now Accepted" do
        page.find("button[data-target='#exit-from-case']").click
        within '#exit-from-case' do
          fill_in 'Exit Date', with: '2017-07-07'
          fill_in 'Exit Note', with: FFaker::Lorem.paragraph
        end
        page.find("input[type='submit'][value='Exit']").click

        expect(accepted_client.reload.status).to eq('Accepted')
      end
    end
  end

  feature 'Enable Edit Emergency Care' do
    let!(:client) { create(:client, :accepted) }
    let!(:ec_case){ create(:case, :emergency, client: client) }

    before do
      login_as(admin)
      visit client_path(client)
    end

    it { expect(page).to have_link(nil, href: edit_client_case_path(client, ec_case)) }
  end

  feature 'Case notes, Assessments, Custom Field and Program Stream permission', js: true do
    let!(:client){ create(:client, :accepted, users: [user]) }
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
        expect(client_case_notes_path(client)).to have_content(current_path)

        find("a[href='#{edit_client_case_note_path(client, case_note)}']").click
        expect(edit_client_case_note_path(client, case_note)).to have_content(current_path)
      end

      scenario 'assessments' do
        find("a[href='#{client_assessments_path(client)}']").click
        find("a[href='#{client_assessment_path(client, assessment)}']").click
        expect(client_assessment_path(client, assessment)).to have_content(current_path)

        find("a[href='#{edit_client_assessment_path(client, assessment)}']").click
        expect(edit_client_assessment_path(client, assessment)).to have_content(current_path)
      end

      scenario 'custom fields' do
        find("a[href='#{client_custom_field_properties_path(client, custom_field_id: custom_field.id)}']", visible: false).trigger('click')
        expect(page).to have_content(custom_field.form_title)

        find("a[href='#{edit_client_custom_field_property_path(client, custom_field_property, custom_field_id: custom_field.id)}']").click
        expect(edit_client_custom_field_property_path(client, custom_field_property, custom_field_id: custom_field.id)).to have_content(current_path)
      end

      scenario 'program streams' do
        find("a[href='#{client_client_enrolled_programs_path(client)}']").click
        expect(client_client_enrolled_programs_path(client)).to have_content(current_path)

        visit edit_client_client_enrolled_program_path(client, client_enrollment, program_stream_id: program_stream.id)

        expect(edit_client_client_enrolled_program_path(client, client_enrollment, program_stream_id: program_stream.id)).to have_content(current_path)
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

        visit client_case_notes_path(client)
        expect(dashboards_path).to have_content(current_path)
      end

      scenario 'assessments' do
        user.permission.update(assessments_readable: false, assessments_editable: false)
        find("a[href='#{client_assessments_path(client)}']").click
        expect(page).not_to have_link("a[href='#{client_assessment_path(client, assessment)}']")

        visit edit_client_assessment_path(client, assessment)
        expect(dashboards_path).to have_content(current_path)

        visit client_assessment_path(client, assessment)
        expect(dashboards_path).to have_content(current_path)
      end

      scenario 'custom fields' do
        user.custom_field_permissions.find_by(custom_field_id: custom_field.id).update(readable: false, editable: false)
        expect(page).not_to have_link("a[href='#{client_custom_field_properties_path(client, custom_field_id: custom_field.id)}']")

        visit edit_client_custom_field_property_path(client, custom_field_property, custom_field_id: custom_field.id)
        expect(dashboards_path).to have_content(current_path)

        visit client_custom_field_properties_path(client, custom_field_property, custom_field_id: custom_field.id)
        expect(dashboards_path).to have_content(current_path)
      end

      scenario 'program streams' do
        user.program_stream_permissions.find_by(program_stream_id: program_stream.id).update(readable: false, editable: false)
        find("a[href='#{client_client_enrolled_programs_path(client)}']").click
        expect(page).not_to have_content(program_stream.name)

        visit edit_client_client_enrolled_program_path(client, client_enrollment, program_stream_id: program_stream.id)
        expect(dashboards_path).to have_content(current_path)

        visit client_client_enrolled_program_path(client, client_enrollment, program_stream_id: program_stream.id)
        expect(dashboards_path).to have_content(current_path)
      end
    end
  end

  feature 'Reject Referral / Exited Client', js: true do
    let!(:client){ create(:client) }
    let!(:accepted_client){ create(:client, :accepted) }

    let!(:active_client){ create(:client, :accepted) }
    let!(:program_stream){ create(:program_stream) }
    let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream, client: active_client) }

    before { login_as(admin) }

    scenario 'Reject client after created' do
      visit client_path(client)
      click_button 'Reject'
      fill_in 'exit_ngo_exit_date', with: Date.today
      page.has_field?('exit_ngo[exit_circumstance]', with: 'Rejected Referral')
      fill_in 'exit_ngo_exit_note', with: 'Note'
      first('.icheckbox_square-green', visible: false).trigger('click')
      find("input[type='submit'][value='Exit']").click

      expect(client.reload.exit_ngos.last.exit_circumstance).to eq('Rejected Referral')
      expect(client.reload.status).to eq('Exited')
    end

    scenario 'Exit client after accepted' do
      visit client_path(accepted_client)
      click_button 'add-client-to-case'
      find("a[data-target='#exitFromNgo']").click
      fill_in 'exit_ngo_exit_date', with: Date.today
      fill_in 'exit_ngo_exit_note', with: 'Note'
      page.has_field?('exit_ngo[exit_circumstance]', with: 'Exited Client')
      first('.icheckbox_square-green', visible: false).trigger('click')
      find("input[type='submit'][value='Exit']").click

      expect(accepted_client.reload.exit_ngos.last.exit_circumstance).to eq('Exited Client')
      expect(accepted_client.reload.status).to eq('Exited')
    end

    context 'Client still actively enrolled in a program' do
      scenario 'Pop up warning' do
        visit client_path(active_client)
        click_button 'add-client-to-case'
        find("a[data-target='#remaining-programs-modal']").click
        expect(page).to have_content('This client is still actively enrolled in 1 programs.')
        expect(page).to have_link('Click here to exit program')
      end
    end
  end

  feature 'Accept' do
    before do
      login_as(admin)
    end

    context 'click Accept initial client' do
      let!(:client) { create(:client) }

      it "status is now Accepted" do
        visit client_path(client)

        find(".form-actions #accept-client").click
        expect(client.reload.status).to eq('Accepted')
      end
    end

    context 'click Accept exited client' do
      let!(:exited_client){ create(:client, :exited) }

      it "status is now Accepted again" do
        visit client_path(exited_client)

        find("button[data-target='#enter-ngo-form']").click
        within '#enter-ngo-form form.simple_form.new_enter_ngo' do
          find("select#enter_ngo_user_ids option[value='#{admin.id}']", visible: false).select_option
          find(".text-right input[type='submit']").click
        end
        expect(exited_client.reload.status).to eq('Accepted')
      end
    end
  end
end

def exit_client_from_ngo
  within '#exitFromNgo form.simple_form.edit_client' do
    fill_in 'client_exit_date', with: Date.today
    fill_in 'client_exit_circumstance', with: 'Testing'
    find("input.confirm-exit").click
  end
  expect(client.reload.status).to eq('Exited')
end

def whodunnit_client(id)
  user_id = PaperTrail::Version.find_by(event: 'create', item_type: 'Client', item_id: id).try(:whodunnit)
  return 'OSCaR Team' if user_id.present? && user_id.include?('@rotati')
  User.find_by(id: user_id).try(:name) || ''
end
