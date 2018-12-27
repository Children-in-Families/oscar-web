describe 'Multi Form' do
  let!(:user){ create(:user) }
  let!(:client_1){ create(:client, :accepted, users: [user]) }
  let!(:client_form_1){ create(:custom_field) }
  let!(:family_form_1){ create(:custom_field, :family) }
  let!(:program_1){ create(:program_stream) }
  let!(:program_2){ create(:program_stream) }
  let!(:tracking_1){ create(:tracking, program_stream: program_1) }
  let!(:tracking_2){ create(:tracking, program_stream: program_2) }
  let!(:enrollment_1){ create(:client_enrollment, program_stream: program_1) }
  let!(:leave_program_1){ create(:leave_program, client_enrollment: enrollment_1, program_stream: program_1) }
  let!(:enrollment_2){ create(:client_enrollment, :active, program_stream: program_2, client: client_1) }

  before do
    login_as(user)
    visit dashboards_path
  end
  xfeature 'List' do
    feature 'forms', js: true do
      scenario 'list only those for clients' do
        page.find('.widget-tasks-panel[data-target="#custom-field"]').click
        wait_for_ajax
        expect(page).to have_content(client_form_1.form_title)
        expect(page).not_to have_content(family_form_1.form_title)
      end
    end
  end

  feature 'New' do
    feature 'forms' do
      scenario 'valid' do
        visit new_multiple_form_custom_field_client_custom_field_path(client_form_1)
        expect(page.status_code).to eq(200)
        expect(page).to have_content(client_form_1.form_title)
      end
      scenario 'invalid' do
        visit new_multiple_form_custom_field_client_custom_field_path(family_form_1)
        expect(page.status_code).to eq(404)
      end
    end
    feature 'trackings' do
      scenario 'valid' do
        visit new_multiple_form_tracking_client_tracking_path(tracking_2)
        expect(page.status_code).to eq(200)
        expect(page).to have_content(tracking_2.name)
      end
      scenario 'invalid' do
        visit new_multiple_form_tracking_client_tracking_path(tracking_1)
        expect(page.status_code).to eq(404)
      end
    end
  end

  feature 'Create', js: true do
    feature 'forms' do
      scenario 'valid' do
        visit new_multiple_form_custom_field_client_custom_field_path(client_form_1)
        find("select#custom_field_property_clients option[value='#{client_1.slug}']", visible: false).select_option
        click_on 'Save'
        wait_for_ajax
        expect(page).to have_content('Form have been added to client(s) successfully')
      end

      xscenario 'invalid' do
        visit new_multiple_form_custom_field_client_custom_field_path(client_form_1)
        click_on 'Save'
        expect(page).to have_content("can't be blank") # no clients selected
      end
    end

    feature 'trackings' do
      scenario 'valid' do
        visit new_multiple_form_tracking_client_tracking_path(tracking_2)
        find("select#client_enrollment_tracking_clients option[value='#{client_1.slug}']", visible: false).select_option
        fill_in 'client_enrollment_tracking_properties_age', with: 2
        fill_in 'client_enrollment_tracking_properties_description', with: FFaker::Lorem.paragraph
        fill_in 'client_enrollment_tracking_properties_e-mail', with: FFaker::Internet.email
        click_on 'Save'
        wait_for_ajax
        expect(page).to have_content('Form have been added to client(s) successfully')
      end

      xscenario 'invalid' do
        visit new_multiple_form_tracking_client_tracking_path(tracking_2)
        click_on 'Save'
        expect(page).to have_content("can't be blank") # no clients selected
      end
    end
  end
end
