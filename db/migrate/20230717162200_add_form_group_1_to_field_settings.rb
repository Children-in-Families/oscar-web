class AddFormGroup1ToFieldSettings < ActiveRecord::Migration
  def change
    add_column :field_settings, :form_group_1, :string
    add_column :field_settings, :form_group_2, :string
    add_column :field_settings, :heading, :string

    reversible do |dir|
      dir.up do
        groups = FieldSetting.pluck(:group).uniq

        groups.each do |group|
          FieldSetting.where(group: group).update_all(form_group_1: group)
        end

        FieldSetting.where(group: 'carer').update_all(form_group_1: 'client')
        FieldSetting.where(group: 'referee').update_all(form_group_1: 'client')
        FieldSetting.where(group: 'school_information').update_all(form_group_1: 'client')

        FieldSetting.where(form_group_1: 'client', name: %w(received_by received_by_id initial_referral_date user_ids followed_up_by_id follow_up_date referee_called_before referee_address)).update_all(form_group_2: 'referee_info_tab')

        FieldSetting.where(form_group_1: 'client', name: %w(referral_info given_name family_name local_given_name local_family_name gender birth_province client_phone phone_owner)).update_all(form_group_2: 'client_info_tab')

        FieldSetting.where(form_group_1: 'client', name: %w(carer_information name phone email school_name school_grade main_school_contact rated_for_id_poor)).update_all(form_group_2: 'client_more_info_tab')
        FieldSetting.where(form_group_1: 'client', name: %w(relevant_referral_information)).update_all(form_group_2: 'protection_concern_tab')

        FieldSetting.where(group: 'family_member').update_all(form_group_1: 'family')
        FieldSetting.where(group: 'family', name: %w(caregiver_information province_id district_id commune_id village_id street house dependable_income household_income contract_date gender)).update_all(form_group_2: 'basic_info_tab')
        FieldSetting.where(group: 'family_member', name: %w(name gender guardian relation occupation adult_name)).update_all(form_group_2: 'family_member_tab')
        
        FieldSetting.where(group: 'case_note').update_all(form_group_1: 'case_management_tool')
        FieldSetting.where(group: 'assessment').update_all(form_group_1: 'case_management_tool')
        
        FieldSetting.where(form_group_1: 'client', name: %w(assessment)).update_all(form_group_1: 'case_management_tool', form_group_2: 'assessment')
        FieldSetting.where(form_group_1: 'case_management_tool', name: %w(reason)).update_all(form_group_2: 'assessment')
        
        FieldSetting.where(form_group_1: 'client', name: %w(national_id passport family_book birth_cert)).update_all(form_group_1: 'additional_field_setting', form_group_2: 'legal_documentations', heading: 'Identification Documents')

        FieldSetting.where(form_group_1: 'client', name: %w(ngo_partner mosavy dosavy msdhs)).update_all(form_group_1: 'additional_field_setting', form_group_2: 'legal_documentations', heading: 'Referral Documents')

        FieldSetting.where(form_group_1: 'client', name: %w(complain warrant verdict)).update_all(form_group_1: 'additional_field_setting', form_group_2: 'legal_documentations', heading: 'Legal Proceeding Documents')

        FieldSetting.where(form_group_1: 'client', name: %w(short_form_of_ocdm short_form_of_mosavy_dosavy detail_form_of_mosavy_dosavy short_form_of_judicial_police detail_form_of_judicial_police other_legal_doc)).update_all(form_group_1: 'additional_field_setting', form_group_2: 'legal_documentations', heading: 'Form for Identification of Victim of Human Trafficking')

        # FieldSetting.where(form_group_1: 'client', name: %w(short_form_of_ocdm short_form_of_mosavy_dosavy detail_form_of_mosavy_dosavy short_form_of_judicial_police detail_form_of_judicial_police other_legal_doc)).update_all(form_group_1: 'additional_field_setting', form_group_2: 'legal_documentations', heading: 'Temporary Travel Documents')

        FieldSetting.where(group: 'stakeholder_contacts').update_all(form_group_1: 'additional_field_setting', form_group_2: 'stakeholder_contacts')
        FieldSetting.where(group: 'pickup_information').update_all(form_group_1: 'additional_field_setting', form_group_2: 'pickup_information')

        FieldSetting.where(form_group_1: 'client', name: %w(police_interview marital_status nationality ethnicity location_of_concern type_of_trafficking department national_id_number passport_number complete_screening_assessment view_screening_assessment education_background)).update_all(form_group_1: 'additional_field_setting', form_group_2: 'field_setting_basic_info')

        FieldSetting.where(name: 'government_forms').update_all(form_group_1: 'case_management_tool', form_group_2: 'cmt_government_form')
      end
    end
  end
end
