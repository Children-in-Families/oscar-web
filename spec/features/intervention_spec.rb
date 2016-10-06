describe 'Intervention' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:intervention){ create(:intervention, action: 'AAA') }

  before do
    login_as(admin)
  end

  feature 'List' do
    before do
      FactoryGirl.create_list(:intervention, 20)
      visit interventions_path
    end

    scenario 'action' do
      expect(page).to have_content(intervention.action)
    end

    scenario 'edit link' do
      expect(page).to have_link(nil, edit_intervention_path(intervention))
    end

    scenario 'delete link' do
      expect(page).to have_css("a[href='#{intervention_path(intervention)}'][data-method='delete']")
    end

    scenario 'new link' do
      expect(page).to have_link(I18n.t('interventions.index.add_new_intervention'), new_intervention_path)
    end

    scenario 'pagination' do
      expect(page).to have_css('.pagination')
    end
  end

  feature 'Create' do
    before do
      visit new_intervention_path
    end

    scenario 'valid' do
      fill_in I18n.t('interventions.form.action'), with: FFaker::HealthcareIpsum.word
      click_button I18n.t('interventions.form.save')
      expect(page).to have_content(I18n.t('interventions.create.successfully_created'))
    end

    scenario 'invalid' do
      click_button I18n.t('interventions.form.save')
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Edit' do
    let!(:action) { FFaker::HealthcareIpsum.word }
    let!(:other_intervention) { create(:intervention, action: 'Counseling') }
    before do
      visit edit_intervention_path(intervention)
    end
    scenario 'valid' do
      fill_in I18n.t('interventions.form.action'), with: action
      click_button I18n.t('interventions.form.save')
      expect(page).to have_content(I18n.t('interventions.update.successfully_updated'))
      expect(page).to have_content(action)
    end
    scenario 'invalid' do
      fill_in I18n.t('interventions.form.action'), with: 'Counseling'
      click_button I18n.t('interventions.form.save')
      expect(page).to have_content(I18n.t('activerecord.errors.models.intervention.attributes.action.taken'))
    end
  end

  feature 'Delete' do
    before do
      visit interventions_path
    end
    scenario 'success' do
      find("a[href='#{intervention_path(intervention)}'][data-method='delete']").click
      expect(page).to have_content(I18n.t('interventions.destroy.successfully_deleted'))
    end
  end
end
