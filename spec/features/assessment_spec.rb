describe "Assessment" do
  let!(:user) { create(:user) }
  let!(:admin) { create(:user, :admin) }
  let!(:strategic_overviewer_1){ create(:user, :strategic_overviewer) }
  let!(:user_2){ create(:user) }
  let!(:client) { create(:client, :accepted, users: [user]) }
  let!(:client_a) { create(:client, :accepted, users: [user, user_2]) }
  let!(:client_b) { create(:client, :accepted, users: [user, user_2]) }
  let!(:fc_case) { create(:case, case_type: 'FC', client: client) }
  let!(:family) { create(:family, :active, user: user) }
  let!(:domain) { create(:domain) }
  let!(:assessment_a){ create(:assessment, client: client_a) }
  let!(:assessment_b){ create(:assessment, client: client_b, created_at: 1.week.ago) } # this is 8 days

  before do
    login_as(user)
  end

  feature 'Create' do
    before do
      login_as(admin)
      visit new_client_assessment_path(client, default: true)
    end

    def add_tasks(n)
      (1..n).each do |time|
        find('.assessment-task-btn').trigger('click')
        fill_in 'task_name', with: 'ABC'
        fill_in 'task_completion_date', with: date_format(Date.strptime(FFaker::Time.date))
        find('.add-task-btn').trigger('click')
        sleep 1
      end
    end

    scenario  'invalid for client', js: true do
      click_link 'Done'
      expect(page).to have_content('This field is required')
    end

    scenario  'valid for client', js: true do
      fill_in 'assessment_assessment_domains_attributes_0_reason', with: FFaker::Lorem.paragraph
      choose('1')
      click_link 'Done'
      sleep 1
      expect(page).to have_content('Assessment has been successfully created.')
      visit client_assessment_path(client, client.assessments.first)
      expect(page).to have_content("Case Plan for #{client.name}")
      expect(page).to have_content(domain.name.downcase.reverse)
    end

    scenario 'valid for family', js: true do
      visit new_family_assessment_path(family, default: true)
      fill_in 'assessment_assessment_domains_attributes_0_reason', with: FFaker::Lorem.paragraph
      choose('1')
      click_link 'Done'
      sleep 1
      expect(page).to have_content('Assessment has been successfully created.')
      visit family_assessment_path(family, family.assessments.first)
      expect(page).to have_content(domain.name)
      expect(page).to have_content("Case Plan for #{family.name}")
    end

    scenario  'invalid for family', js: true do
      click_link 'Done'
      expect(page).to have_content('This field is required')
    end

    context 'assessments editable permission' do
      scenario 'user has editable permission' do
        expect(new_client_assessment_path(client)).to have_content(current_path)
      end

      scenario 'user does not have editable permission' do
        login_as(user)
        user.permission.update(assessments_editable: false)
        visit new_client_assessment_path(client)
        expect(dashboards_path).to have_content(current_path)
      end
    end
  end

  feature 'List' do
    before { Setting.first.update(enable_custom_assessment: true) }

    let!(:assessment){ create(:assessment, client: client) }
    let!(:assessment_domain){ create(:assessment_domain, assessment: assessment, domain: domain) }
    let!(:client_1){ create(:client, :accepted, users: [user]) }
    let!(:client_2){ create(:client, :accepted, users: [user]) }
    # let!(:assessment_1){ create(:assessment, created_at: Time.now - 3.months, client: client_1) }
    # let!(:assessment_2){ create(:assessment, created_at: Time.now - 4.months, client: client_2) }
    let!(:last_assessment_domain){ create(:assessment_domain, assessment: assessment_1, domain: domain) }

    let(:setting) { Setting.first }
    let!(:assessment_1){ create(:assessment, created_at: Time.now - 3.months, client: client_1) }
    let!(:assessment_2){ create(:assessment, created_at: Time.now - (setting.max_assessment).months, client: client_2) }
    let!(:custom_assessment_1){ create(:assessment, created_at: Time.now - 3.months, client: client_1, default: false) }
    let!(:custom_assessment_2){ create(:assessment, created_at: Time.now - (setting.max_custom_assessment).months, client: client_2, default: false) }

    before do
      visit client_assessments_path(client)
    end

    scenario 'view report' do
      expect(page).to have_link('View Report', href: client_assessment_path(client, assessment))
    end

    scenario 'no new assessment' do
      expect(page).not_to have_link('Add New Assessment', href: new_client_assessment_path(client))
    end

    feature 'new assessment is enable for user to create as often as they like' do
      context 'CSI Assessment' do
        scenario 'after minimum assessment duration' do
          visit client_assessments_path(client_1)
          expect(page).to have_link('Add New CSI Assessment', href: new_client_assessment_path(client_1, default: true))
        end
        scenario 'after maximum assessment duration' do
          visit client_assessments_path(client_2)
          expect(page).to have_link('Add New CSI Assessment', href: new_client_assessment_path(client_2, default: true))
        end
      end
    end

    context 'assessments readable permission' do
      scenario 'user has readable permission' do
        expect(client_assessments_path(client)).to have_content(current_path)
      end

      scenario 'user does not have readable permission' do
        user.permission.update(assessments_readable: false)
        visit client_assessment_path(client, assessment)
        expect(dashboards_path).to have_content(current_path)
      end
    end
  end

  feature 'Update' do
    let!(:assessment){ create(:assessment, client: client) }

    context 'assessments editable permission' do
      scenario 'user has editable permission' do
        visit edit_client_assessment_path(client, assessment)
        expect(edit_client_assessment_path(client, assessment)).to have_content(current_path)
      end

      scenario 'user does not have editable permission' do
        user.permission.update(assessments_editable: false)

        visit edit_client_assessment_path(client, assessment)
        expect(dashboards_path).to have_content(current_path)
      end
    end
  end
end
