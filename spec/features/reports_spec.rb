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
    xscenario 'CSI Domain Score' do
      expect(page).to have_content(I18n.t('reports.index.csi_domain_scores'))
    end
    scenario 'Case Type Statistic' do
      expect(page).to have_content(I18n.t('reports.index.case_statistics'))
    end

    scenario 'search' do
      expect(page).to have_content(I18n.t('reports.form.start_date'))
      expect(page).to have_content(I18n.t('reports.form.end_date'))
      expect(page).to have_css('.statistic-btn')
    end
  end
end
