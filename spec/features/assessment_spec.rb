describe "Assessment" do
  let!(:user) { create(:user) }
  let!(:strategic_overviewer_1){ create(:user, :strategic_overviewer) }
  let!(:user_2){ create(:user) }
  let!(:client) { create(:client, :accepted, users: [user]) }
  let!(:client_a) { create(:client, :accepted, users: [user, user_2]) }
  let!(:client_b) { create(:client, :accepted, users: [user, user_2]) }
  let!(:fc_case) { create(:case, case_type: 'FC', client: client) }
  let!(:domain) { create(:domain) }
  let!(:assessment_a){ create(:assessment, client: client_a) }
  let!(:assessment_b){ create(:assessment, client: client_b, created_at: 1.week.ago) } # this is 8 days

  before do
    login_as(user)
  end

  feature 'show' do
    let!(:domain_1){ create(:domain, score_1_color: 'danger', score_1_definition: 'Poor', score_2_color: 'warning', score_2_definition: 'Good') }
    let!(:assessment_1){ create(:assessment, client: client, created_at: 6.months.ago) }
    let!(:assessment_2){ create(:assessment, client: client) }
    let!(:assessment_domain_1){ create(:assessment_domain, score: 1, assessment: assessment_1, domain: domain_1) }
    let!(:assessment_domain_2){ create(:assessment_domain, previous_score: 1, score: 2, assessment: assessment_2, domain: domain_1) }

    feature 'CSI Assessment' do
      before do
        visit client_assessment_path(client, assessment_2)
      end

      scenario 'Case Plan' do
        expect(page).to have_content("Case Plan for #{client.name}")
        expect(page).to have_content("Based on Assessment Number 2")
        expect(page).to have_content("Completed by OSCaR Team on #{date_format(Date.today)}")
        expect(page).to have_css('.btn-danger[data-toggle="tooltip"][data-original-title="<p>Poor</p>"]', text: '1')
        expect(page).to have_css('.btn-warning[data-toggle="tooltip"][data-original-title="<p>Good</p>"]', text: '2')
      end

      scenario 'status' do
        expect(page).to have_content('Completed')
      end

      context 'edit link' do
        context 'log in as case worker / manager / admin' do
          context 'visible within 1 week' do
            scenario 'eligiable age' do
              visit client_assessment_path(client_a, assessment_a)

              expect(page).to have_link(nil, href: edit_client_assessment_path(client_a, assessment_a))
            end
            scenario 'uneligiable age' do
              client_a.update(date_of_birth: 20.years.ago)
              visit client_assessment_path(client_a, assessment_a)

              expect(page).to have_link(nil, href: edit_client_assessment_path(client_a, assessment_a))
            end
          end

          scenario 'invisible after 1 week' do
            visit client_assessment_path(client_b, assessment_b)

            expect(page).not_to have_link(nil, href: edit_client_assessment_path(client_b, assessment_b))
          end
        end

        context 'log in as strategic overviewer' do
          before do
            login_as(strategic_overviewer_1)
          end

          scenario 'invisible' do
            visit client_assessment_path(client_b, assessment_b)
            expect(page).not_to have_link(nil, href: edit_client_assessment_path(client_b, assessment_b))
          end
        end
      end
    end

    feature 'Custom Assessment', js: true do
      before { Setting.first.update(enable_custom_assessment: true) }
      let!(:custom_assessment_1){ create(:assessment, client: client, default: false) }

      context 'is not enabled' do
        scenario 'unauthorized' do
          Setting.first.update(enable_custom_assessment: false)
          visit client_assessment_path(client, custom_assessment_1)

          expect(page).to have_content('You are not authorized to access this page.')
        end
      end
    end

  end

  feature 'Create' do
    before do
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

    def with_tasks(n)
      choose('1')
      expect(page).to have_css('.label-danger')
      expect(page).to have_css('.assessment-task-btn')
      add_tasks(n)
    end

    def without_task
      choose('4')
      expect(page).to have_css('.label-success')
      expect(page).not_to have_css('.label-danger')
      expect(page).not_to have_css('.label-warning')
      expect(page).not_to have_css('.label-info')
    end

    scenario 'valid', js: true do
      with_tasks(1)
      without_task

      fill_in 'assessment_assessment_domains_attributes_0_reason', with: FFaker::Lorem.paragraph
      fill_in "goal-text-area-#{domain.name.downcase.split.join('-')}", with: FFaker::Lorem.paragraph

      click_link 'Done'
      sleep 1
      expect(page).to have_content(domain.name)
      expect(page.find('.domain-score')).to have_content('4')
      expect(Task.find_by(name: 'ABC').user_id).to eq(user.id)
    end

    scenario  'invalid', js: true do
      choose('1')

      fill_in 'assessment_assessment_domains_attributes_0_reason', with: FFaker::Lorem.paragraph

      click_link 'Done'
      expect(page).to have_content('This field is required')
    end

    context 'assessments editable permission' do
      scenario 'user has editable permission' do
        expect(new_client_assessment_path(client)).to have_content(current_path)
      end

      scenario 'user does not have editable permission' do
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

      context 'Custom Assessment' do
        let!(:domain_1){ create(:domain, custom_domain: true) }
        scenario 'after minimum assessment duration' do
          visit client_assessments_path(client_1)
          expect(page).to have_link('Add New Custom Assessment', href: new_client_assessment_path(client_1, default: false))
        end
        scenario 'after maximum assessment duration' do
          visit client_assessments_path(client_2)
          expect(page).to have_link('Add New Custom Assessment', href: new_client_assessment_path(client_2, default: false))
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

    let!(:client_3){ create(:client, :accepted, users: [user], date_of_birth: 18.years.ago) }
    scenario 'create assessment button is disable for client whose age is over 18' do
      visit client_assessments_path(client_3)
      expect(page).to have_css('#disabled_assessment_button')
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
