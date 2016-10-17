describe "Assessment" do
  let!(:user) { create(:user) }
  let!(:client) { create(:client, state: 'accepted', user: user) }
  let!(:fc_case) { create(:case, case_type: 'FC', client: client) }
  let!(:domain) { create(:domain, name: FFaker::Name.name) }

  before do
    login_as(user)
  end

  feature 'Create' do
    before do
      visit new_client_assessment_path(client)
    end

    def add_tasks(n)
      (1..n).each do |time|
        find('.assessment-task-btn').click
        fill_in 'task_name', with: FFaker::Lorem.paragraph
        fill_in 'task_completion_date', with: Date.strptime(FFaker::Time.date).strftime('%B %d, %Y')
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
      expect(page).not_to have_css('.assessment-task-btn')
    end

    scenario 'valid', js: true do
      with_tasks(2)
      without_task

      fill_in 'Reason', with: FFaker::Lorem.paragraph
      fill_in 'Goal', with: FFaker::Lorem.paragraph

      click_link 'Done'

      expect(page).to have_content('Assessment has been successfully created')
      expect(page).to have_content(domain.name)
      expect(page.find('.domain-score')).to have_content('4')
    end

    scenario  'invalid', js: true do
      choose('1')
      fill_in 'Reason', with: FFaker::Lorem.paragraph
      click_link 'Done'
      expect(page).to have_content('This field is required')
      expect(page).not_to have_content('Assessment has been successfully created')
    end
  end

  feature 'List' do
    let!(:assessment){ create(:assessment, client: client) }
    let!(:assessment_domain){ create(:assessment_domain, assessment: assessment, domain: domain) }
    let!(:other_client){ create(:client, state: 'accepted', user: user) }
    let!(:last_assessment){ create(:assessment, created_at: Time.now - 7.month, client: other_client) }
    let!(:last_assessment_domain){ create(:assessment_domain, assessment: last_assessment, domain: domain) }

    before do
      visit client_assessments_path(client)
    end

    scenario 'view report' do
      expect(page).to have_link('View Report', href: client_assessment_path(client, assessment))
    end

    scenario 'no new assessment' do
      expect(page).not_to have_link('Begin now', href: new_client_assessment_path(client))
    end

    scenario 'new assessment' do
      visit client_assessments_path(other_client)
      expect(page).to have_link('Begin now', href: new_client_assessment_path(other_client))
    end

  end
end
