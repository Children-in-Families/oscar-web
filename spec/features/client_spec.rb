describe 'Client' do
  let(:admin) { create(:user, roles: 'admin') }
  let(:user) { create(:user) }

  feature 'List' do
    let!(:client){create(:client, user: user)}
    let!(:other_client){create(:client)}
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

  feature 'Show' do
    let!(:client){ create(:client, user: user, state: 'accepted') }
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
    before do
      login_as(user)
      visit new_client_path
    end
    scenario 'valid' do
      fill_in 'Name', with: FFaker::Name.name
      click_button 'Save'
      expect(page).to have_content('Client has been successfully created')
    end

    xscenario 'invalid' do
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Update' do
    let!(:client){ create(:client, user: user) }
    before do
      login_as(user)
      visit edit_client_path(client)
    end
    scenario 'valid' do
      fill_in 'Name', with: FFaker::Name.name
      click_button 'Save'
      expect(page).to have_content('Client has been successfully updated')
    end

    xscenario 'invalid' do
      fill_in 'Name', with: ''
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Delete' do
    let!(:client){ create(:client, user: user) }
    before do
      login_as(user)
      visit clients_path
    end
    scenario 'successfully' do
      first("a[data-method='delete'][href='#{client_path(client)}']").click
      expect(page).to have_content('Client has been successfully deleted')
    end
  end

  feature 'Accept' do
    let!(:client){create(:client, user: user)}
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
    let!(:client){create(:client, user: user)}
    before do
      login_as(user)
      visit client_path(client)
      fill_in 'Note', with: FFaker::Lorem.paragraph
      find("input[type='submit'][value='Reject']").click
    end
    scenario 'successfully' do
      expect(page).to have_content('Client has been successfully updated')
    end
  end

  feature 'Exit' do
    xscenario 'success' do
    end
    xscenario 'disable' do
      visit client_path(other_client)
      expect(page).not_to have_link('Exit From CIF')
    end
  end

  feature 'Accept and Reject' do
    let!(:non_status_client){ create(:client, state: '', user: user) }
    let!(:rejected_client){ create(:client, state: 'rejected', rejected_note: 'Something', user: user) }
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
    let!(:accepted_client){ create(:client, state: 'accepted', user: user) }

    feature 'All Case' do
      let!(:emergency_case){ create(:case, case_type: 'EC', client: accepted_client) }
      let!(:foster_case){ create(:case, case_type: 'FC', client: accepted_client) }
      let!(:kinship_case){ create(:case, case_type: 'KC', client: accepted_client) }

      before do
        login_as(user)
        visit client_path(accepted_client)
      end

      scenario 'All Panel' do
        expect(page).to have_content('Emergency Care')
        expect(page).to have_content('Foster Care')
        expect(page).to have_content('Kinship Care')
      end

      scenario 'Emergency Info' do
        panel = page.all(:css, '.case').select{ |p| p.find('.panel-body .h3-header').text.include?('Emergency Care')}.first

        expect(panel).to have_content(emergency_case.start_date.strftime('%B %d, %Y'))
        expect(panel).to have_content(emergency_case.carer_names)
        expect(panel).to have_content(emergency_case.carer_phone_number)
      end

      scenario 'Foster Info' do
        panel = page.all(:css, '.case').select{ |p| p.find('.panel-body .h3-header').text.include?('Foster Care')}.first

        expect(panel).to have_content(foster_case.carer_address)
        expect(panel).to have_content(foster_case.province.name)
        expect(panel).to have_content(ActionController::Base.helpers.number_to_currency(foster_case.support_amount))
      end

      scenario 'Kinship Info' do
        panel = page.all(:css, '.case').select{ |p| p.find('.panel-body .h3-header').text.include?('Kinship Care')}.first

        expect(panel).to have_content(foster_case.support_note)
        expect(panel).to have_content(foster_case.partner.name)
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
      let!(:blank_client){ create(:client, state: 'accepted', user: user) }

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
    end

    feature 'Emergency Active Client' do
      let!(:ec_client){ create(:client, state: 'accepted', user: user) }
      let!(:case){ create(:case, case_type: 'EC', client: ec_client, exited: false) }

      before do
        login_as(user)
        visit client_path(ec_client)
      end

      scenario 'Emergency Case Button' do
        expect(page).not_to have_link('Add to EC', href: new_client_case_path(ec_client, case_type: 'EC'))
      end

      scenario 'Foster Case Button' do
        expect(page).to have_link('Add to FC', href: new_client_case_path(ec_client, case_type: 'FC'))
      end

      scenario 'Kinship Case Button' do
        expect(page).to have_link('Add to KC', href: new_client_case_path(ec_client, case_type: 'KC'))
      end
    end
    feature 'Not Emergency Active Client' do
      let!(:active_client){ create(:client, state: 'accepted', user: user) }
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
      let!(:inactive_client){ create(:client, state: 'accepted', user: user) }
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
    let!(:accepted_client){ create(:client, state: 'accepted', user: user) }
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
    let(:accepted_client) { create(:client, state: 'accepted', user: user) }
    let!(:client_case) { create(:case, case_type: ['EC', 'FC', 'KC'].sample, client: accepted_client) }

    before do
      login_as(user)
      visit client_path(accepted_client)
    end
    scenario 'Exit Button' do
      button = find("button[data-target='#exitFromCase']")
      expect(button.text).to have_content('Exit')
    end
    scenario 'Note' do
      modal = find(:css, '#exitFromCase')

      modal.find('.exit_date').set(Date.strptime(FFaker::Time.date).strftime('%B %d, %Y'))
      modal.find('.exit_note').set(FFaker::Lorem.paragraph)
      modal.find("input[type='submit'][value='Exit']").click

      expect(page).to have_content('Case has been successfully updated')
    end
  end

  feature 'Time in care' do
    let!(:accepted_client) { create(:client, state: 'accepted', user: user) }
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
end
