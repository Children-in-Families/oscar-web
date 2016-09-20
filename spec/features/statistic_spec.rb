describe 'Statistic' do
  let!(:admin){ create(:user, roles: 'admin') }
  before do 
    login_as(admin)
  end

  feature 'Index' do
    before do
      visit statistics_path
    end
    scenario 'CSI Domain Score' do
      expect(page).to have_content(I18n.t('statistics.index.csi_statistics'))
    end
    scenario 'Case Type Statistic' do
      expect(page).to have_content(I18n.t('statistics.index.case_statistics'))
    end
  end

  feature 'Csi Domain' do
    before do
      visit csi_domain_statistics_path
    end
    scenario 'search' do
      expect(page).to have_content(I18n.t('statistics.csi_form.start_date'))
      expect(page).to have_content(I18n.t('statistics.csi_form.end_date'))
      expect(page).to have_css('.statistic-btn')
    end
    scenario 'title', js: true do
      sleep 1
      expect(page).to have_content(I18n.t('statistics.csi_domain.csi_domain_scores'))
    end
  end

  feature 'Case Type Statistic' do
    before do
      visit case_type_statistics_path
    end
    scenario 'title', js: true do
      sleep 1
      expect(page).to have_content(I18n.t('statistics.case_type.case_statistic'))
    end
  end
end
