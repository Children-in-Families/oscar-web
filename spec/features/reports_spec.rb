describe 'Report' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:client){ create(:client, user: admin) }
  before do 
    login_as(admin)
  end

  feature 'Index' do
    before do
      visit reports_path
    end
    scenario 'CSI Domain Score', js: true do
      sleep 1
      expect(page).to have_content(I18n.t('reports.index.csi_domain_scores'))
    end
    scenario 'Case Type Statistic', js: true do
      sleep 1
      expect(page).to have_content(I18n.t('reports.index.case_statistics'))
    end

    xscenario 'search' do
      expect(page).to have_content(I18n.t('reports.form.start_date'))
      expect(page).to have_content(I18n.t('reports.form.end_date'))
      expect(page).to have_css('.statistic-btn')
    end
  end
end
