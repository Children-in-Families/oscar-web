describe 'VisitClient' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:client_1){ create(:client, given_name: 'Rainy') }
  let!(:client_2){ create(:client) }
  let!(:client_3){ create(:client) }
  before do
    login_as(admin)
  end
  feature 'Client show page' do
    feature 'from clients list/index' do
      before(:each) do
        visit clients_path
      end
      scenario 'increase visit client by 1' do
        first("a[href='#{client_path(client_1)}']").click
        expect(admin.visit_clients.count).to eq(1)
      end
    end

    feature 'from client advanced searches' do
      before(:each) do
        url = '/client_advanced_searches?utf8=%E2%9C%93&client_advanced_search%5Bcustom_form_selected%5D=&client_advanced_search%5Bprogram_selected%5D=&client_advanced_search%5Benrollment_check%5D=&client_advanced_search%5Btracking_check%5D=&client_advanced_search%5Bexit_form_check%5D=&client_advanced_search%5Bbasic_rules%5D=%7B%22condition%22%3A%22AND%22%2C%22rules%22%3A%5B%7B%22id%22%3A%22given_name%22%2C%22field%22%3A%22given_name%22%2C%22type%22%3A%22string%22%2C%22input%22%3A%22text%22%2C%22operator%22%3A%22contains%22%2C%22value%22%3A%22rainy%22%7D%5D%7D&client_advanced_search%5Bquantitative_check%5D=&client_advanced_search%5Bfield_visibility%5D=&locale=en&all_=all&given_name_=given_name&family_name_=family_name&local_given_name_=local_given_name&local_family_name_=local_family_name&gender_=gender&slug_=slug&code_=code&kid_id_=kid_id&status_=status&case_type_=case_type&date_of_birth_=date_of_birth&age_=age&birth_province_id_=birth_province_id&province_id_=province_id&initial_referral_date_=initial_referral_date&referral_phone_=referral_phone&received_by_id_=received_by_id&referral_source_id_=referral_source_id&followed_up_by_id_=followed_up_by_id&follow_up_date_=follow_up_date&agencies_name_=agencies_name&current_address_=current_address&house_number_=house_number&street_number_=street_number&village_=village&commune_=commune&district_=district&school_name_=school_name&has_been_in_government_care_=has_been_in_government_care&grade_=grade&able_state_=able_state&has_been_in_orphanage_=has_been_in_orphanage&relevant_referral_information_=relevant_referral_information&user_ids_=user_ids&donor_=donor&state_=state&family_id_=family_id&any_assessments_=any_assessments&live_with_=live_with&id_poor_=id_poor&program_streams_=program_streams&program_enrollment_date_=program_enrollment_date&program_exit_date_=program_exit_date&accepted_date_=accepted_date&exit_date_=exit_date&history_of_harm_=history_of_harm&history_of_high_risk_behaviours_=history_of_high_risk_behaviours&history_of_disability_and_or_illness_=history_of_disability_and_or_illness&reason_for_family_separation_=reason_for_family_separation&rejected_note_=rejected_note&case_start_date_=case_start_date&carer_names_=carer_names&carer_address_=carer_address&carer_phone_number_=carer_phone_number&support_amount_=support_amount&support_note_=support_note&form_title_=form_title&family_preservation_=family_preservation&family_=family&partner_=partner&manage_=manage&changelog_=changelog'
        visit url
      end
      scenario 'increase visit client by 1' do
        first("a[href='#{client_path(client_1)}']").click
        expect(admin.visit_clients.count).to eq(1)
      end
    end

    feature 'from url/bookmark' do
      before do
        visit client_path(client_1)
      end
      scenario 'does not increase visit client by 1' do
        expect(admin.visit_clients.count).to eq(0)
      end
    end
  end
end
