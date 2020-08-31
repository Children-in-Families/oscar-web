module AdvancedSearchHelper
  include ClientsHelper

  def custom_form_values(report_builder = '#builder')
    has_custom_form_selected = has_advanced_search? && advanced_search_params[:custom_form_selected].present? && (advanced_search_params[:action_report_builder].present? ? report_builder == advanced_search_params[:action_report_builder] : true)
    has_custom_form_selected ? eval(advanced_search_params[:custom_form_selected]) : []
  end

  def program_stream_values(report_builder = '#builder')
    has_program_selected = has_advanced_search? && advanced_search_params[:program_selected].present? && report_builder == advanced_search_params[:action_report_builder]
    has_program_selected ? eval(advanced_search_params[:program_selected]) : []
  end

  def quantitative_check
    has_advanced_search? && advanced_search_params[:quantitative_check].present? ? true : false
  end

  def enrollment_check
    has_advanced_search? && advanced_search_params[:enrollment_check].present? ? true : false
  end

  def tracking_check
    has_advanced_search? && advanced_search_params[:tracking_check].present? ? true : false
  end

  def exit_form_check
    has_advanced_search? && advanced_search_params[:exit_form_check].present? ? true : false
  end

  def hotline_check
    has_advanced_search? && advanced_search_params[:hotline_check].present? ? true : false
  end

  def wizard_enrollment_checked?
    has_advanced_search? && advanced_search_params[:wizard_enrollment_check].present? ? true : false
  end

  def wizard_tracking_checked?
    has_advanced_search? && advanced_search_params[:wizard_tracking_check].present? ? true : false
  end

  def wizard_exit_form_checked?
    has_advanced_search? && advanced_search_params[:wizard_exit_form_check].present? ? true : false
  end

  def wizard_custom_form_checked?
    has_advanced_search? && advanced_search_params[:wizard_custom_form_check].present? ? true : false
  end

  def wizard_program_stream_checked?
    has_advanced_search? && advanced_search_params[:wizard_program_stream_check].present? ? true : false
  end

  def wizard_quantitative_checked?
    has_advanced_search? && advanced_search_params[:wizard_quantitative_check].present? ? true : false
  end

  def has_advanced_search?
    params[:client_advanced_search].present? || params[:family_advanced_search].present? || params[:partner_advanced_search].present?
  end

  def advanced_search_params
    params[:client_advanced_search] || params[:family_advanced_search] || params[:partner_advanced_search]
  end

  def format_header(key)
    translations = {
      # national_id_number: I18n.t('datagrid.columns.clients.national_id_number'),
      # passport_number: I18n.t('datagrid.columns.clients.passport_number'),
      # marital_status: I18n.t('datagrid.columns.clients.marital_status'),
      # nationality: I18n.t('datagrid.columns.clients.nationality'),
      # ethnicity: I18n.t('datagrid.columns.clients.ethnicity'),
      # location_of_concern: I18n.t('datagrid.columns.clients.location_of_concern'),
      # type_of_trafficking: I18n.t('datagrid.columns.clients.type_of_trafficking'),
      # education_background: I18n.t('datagrid.columns.clients.education_background'),
      # department: I18n.t('datagrid.columns.clients.department'),
      # presented_id: I18n.t('datagrid.columns.clients.presented_id'),
      # id_number: I18n.t('datagrid.columns.clients.id_number'),
      # legacy_brcs_id: I18n.t('datagrid.columns.clients.legacy_brcs_id'),
      # whatsapp: I18n.t('datagrid.columns.clients.whatsapp'),
      # other_phone_number: I18n.t('datagrid.columns.clients.other_phone_number'),
      # brsc_branch: I18n.t('datagrid.columns.clients.brsc_branch'),
      # preferred_language: I18n.t('datagrid.columns.clients.preferred_language'),
      # current_island: I18n.t('datagrid.columns.current_address', column: I18n.t('datagrid.columns.clients.current_island')),
      # current_street: I18n.t('datagrid.columns.current_address', column: I18n.t('datagrid.columns.clients.current_street')),
      # current_po_box: I18n.t('datagrid.columns.current_address', column: I18n.t('datagrid.columns.clients.current_po_box')),
      # current_city: I18n.t('datagrid.columns.current_address', column: I18n.t('datagrid.columns.clients.current_city')),
      # current_settlement: I18n.t('datagrid.columns.current_address', column: I18n.t('datagrid.columns.clients.current_settlement')),
      # current_resident_own_or_rent: I18n.t('datagrid.columns.current_address', column: I18n.t('datagrid.columns.clients.current_resident_own_or_rent')),
      # current_household_type: I18n.t('datagrid.columns.current_address', column: I18n.t('datagrid.columns.clients.current_household_type')),
      # island2: I18n.t('datagrid.columns.other_address', column: I18n.t('datagrid.columns.clients.island2')),
      # street2: I18n.t('datagrid.columns.other_address', column: I18n.t('datagrid.columns.clients.street2')),
      # po_box2: I18n.t('datagrid.columns.other_address', column: I18n.t('datagrid.columns.clients.po_box2')),
      # city2: I18n.t('datagrid.columns.other_address', column: I18n.t('datagrid.columns.clients.city2')),
      # settlement2: I18n.t('datagrid.columns.other_address', column: I18n.t('datagrid.columns.clients.settlement2')),
      # resident_own_or_rent2: I18n.t('datagrid.columns.other_address', column: I18n.t('datagrid.columns.clients.resident_own_or_rent2')),
      # household_type2: I18n.t('datagrid.columns.other_address', column: I18n.t('datagrid.columns.clients.household_type2')),
      given_name: I18n.t('advanced_search.fields.given_name'),
      family_name: I18n.t('advanced_search.fields.family_name'),
      # national_id: I18n.t('datagrid.columns.clients.national_id'),
      # birth_cert: I18n.t('datagrid.columns.clients.birth_cert'),
      # family_book: I18n.t('datagrid.columns.clients.family_book'),
      # passport: I18n.t('datagrid.columns.clients.passport'),
      # travel_doc: I18n.t('datagrid.columns.clients.travel_doc'),
      # referral_doc: I18n.t('datagrid.columns.clients.referral_doc'),
      # local_consent: I18n.t('datagrid.columns.clients.local_consent'),
      # police_interview: I18n.t('datagrid.columns.clients.police_interview'),
      # other_legal_doc: I18n.t('datagrid.columns.clients.other_legal_doc'),
      local_given_name: "#{I18n.t('advanced_search.fields.local_given_name')} #{country_scope_label_translation}",
      local_family_name: "#{I18n.t('advanced_search.fields.local_family_name')} #{country_scope_label_translation}",
      carer_name: I18n.t('activerecord.attributes.carer.name'),
      carer_phone: I18n.t('activerecord.attributes.carer.phone'),
      carer_email: I18n.t('activerecord.attributes.carer.email'),
      client_contact_phone: I18n.t('advanced_search.fields.client_contact_phone'),
      address_type: I18n.t('advanced_search.fields.address_type'),
      client_email_address: I18n.t('advanced_search.fields.client_email_address'),
      code: custom_id_translation('custom_id1'),
      school_grade: I18n.t('advanced_search.fields.school_grade'),
      family_id: I18n.t('advanced_search.fields.family_id'),
      age: I18n.t('advanced_search.fields.age'),
      family: I18n.t('advanced_search.fields.family'),
      slug: I18n.t('advanced_search.fields.slug'),
      referral_phone: I18n.t('advanced_search.fields.referral_phone'),
      house_number: I18n.t('advanced_search.fields.house_number'),
      street_number: I18n.t('advanced_search.fields.street_number'),
      commune_id: I18n.t('advanced_search.fields.commune'),
      village_id: I18n.t('advanced_search.fields.village'),
      suburb: I18n.t('advanced_search.fields.suburb'),
      description_house_landmark: I18n.t('advanced_search.fields.description_house_landmark'),
      directions: I18n.t('advanced_search.fields.directions'),
      street_line1: I18n.t('advanced_search.fields.street_line1'),
      street_line2: I18n.t('advanced_search.fields.street_line2'),
      phone_owner: I18n.t('advanced_search.fields.phone_owner'),
      plot: I18n.t('advanced_search.fields.plot'),
      road: I18n.t('advanced_search.fields.road'),
      postal_code: I18n.t('advanced_search.fields.postal_code'),
      district_id: I18n.t('advanced_search.fields.district'),
      subdistrict_id: I18n.t('advanced_search.fields.subdistrict'),
      township_id: I18n.t('advanced_search.fields.township'),
      state_id: I18n.t('advanced_search.fields.state'),
      school_name: I18n.t('advanced_search.fields.school_name'),
      placement_date: I18n.t('advanced_search.fields.placement_start_date'),
      date_of_birth: I18n.t('advanced_search.fields.date_of_birth'),
      initial_referral_date: I18n.t('advanced_search.fields.initial_referral_date'),
      follow_up_date: I18n.t('advanced_search.fields.follow_up_date'),
      gender: I18n.t('datagrid.columns.clients.gender'),
      status: I18n.t('advanced_search.fields.status'),
      agency_name: I18n.t('advanced_search.fields.agency_name'),
      donor_name: I18n.t('advanced_search.fields.donor_id'),
      received_by_id: I18n.t('advanced_search.fields.received_by_id'),
      birth_province_id: I18n.t('advanced_search.fields.birth_province_id'),
      province_id: I18n.t('advanced_search.fields.province_id'),
      referral_source_id: I18n.t('advanced_search.fields.referral_source_id'),
      followed_up_by_id: I18n.t('advanced_search.fields.followed_up_by_id'),
      has_been_in_government_care: I18n.t('advanced_search.fields.has_been_in_government_care'),
      able_state: I18n.t('advanced_search.fields.able_state'),
      has_been_in_orphanage: I18n.t('advanced_search.fields.has_been_in_orphanage'),
      user_id: I18n.t('advanced_search.fields.user_id'),
      # id_poor: I18n.t('advanced_search.fields.id_poor'),
      enrollment: I18n.t('advanced_search.fields.enrollment'),
      tracking: I18n.t('advanced_search.fields.tracking'),
      exit_program: I18n.t('advanced_search.fields.exit_program'),
      basic_fields: I18n.t('advanced_search.fields.basic_fields'),
      custom_form: I18n.t('advanced_search.fields.custom_form'),
      quantitative: I18n.t('advanced_search.fields.quantitative'),
      exit_date: I18n.t('advanced_search.fields.ngo_exit_date'),
      accepted_date: I18n.t('advanced_search.fields.ngo_accepted_date'),
      active_program_stream: I18n.t('advanced_search.fields.active_program_stream'),
      enrolled_program_stream: I18n.t('advanced_search.fields.enrolled_program_stream'),
      csi_domain_scores: I18n.t('advanced_search.fields.csi_domain_scores'),
      custom_csi_domain_scores: I18n.t('advanced_search.fields.custom_csi_domain_scores'),
      case_note_date: I18n.t('advanced_search.fields.case_note_date'),
      case_note_type: I18n.t('advanced_search.fields.case_note_type'),
      date_of_assessments: I18n.t('advanced_search.fields.date_of_assessments', assessment: I18n.t('clients.show.assessment')),
      date_of_referral: I18n.t('advanced_search.fields.date_of_referral'),
      telephone_number: I18n.t('advanced_search.fields.telephone_number'),
      exit_circumstance: I18n.t('advanced_search.fields.exit_circumstance'),
      exit_reasons: I18n.t('advanced_search.fields.exit_reasons'),
      other_info_of_exit: I18n.t('advanced_search.fields.other_info_of_exit'),
      exit_note: I18n.t('advanced_search.fields.exit_note'),
      rated_for_id_poor: I18n.t('advanced_search.fields.rated_for_id_poor'),
      name_of_referee: I18n.t('advanced_search.fields.name_of_referee'),
      main_school_contact: I18n.t('advanced_search.fields.main_school_contact'),
      what3words: I18n.t('advanced_search.fields.what3words'),
      kid_id: custom_id_translation('custom_id2'),
      created_at: I18n.t('advanced_search.fields.created_at'),
      created_by: I18n.t('advanced_search.fields.created_by'),
      referred_to: I18n.t('advanced_search.fields.referred_to'),
      referred_from: I18n.t('advanced_search.fields.referred_from'),
      referee_name: I18n.t('advanced_search.fields.referee_name'),
      referee_phone: I18n.t('advanced_search.fields.referee_phone'),
      referee_email: I18n.t('advanced_search.fields.referee_email'),
      referee_relationship: I18n.t('advanced_search.fields.referee_relationship'),
      # time_in_care: I18n.t('advanced_search.fields.time_in_care'),
      time_in_cps: I18n.t('advanced_search.fields.time_in_cps'),
      time_in_ngo: I18n.t('advanced_search.fields.time_in_ngo'),
      assessment_number: I18n.t('advanced_search.fields.assessment_number', assessment: I18n.t('clients.show.assessment')),
      assessment_completed_date: I18n.t('advanced_search.fields.assessment_completed_date', assessment: I18n.t('clients.show.assessment')),
      month_number: I18n.t('advanced_search.fields.month_number'),
      custom_csi_group: I18n.t('advanced_search.fields.custom_csi_group'),
      referral_source_category_id: I18n.t('advanced_search.fields.referral_source_category_id'),
      type_of_service:  I18n.t('advanced_search.fields.type_of_service'),
      hotline: I18n.t('datagrid.columns.calls.hotline')
    }

    # Client::STACKHOLDER_CONTACTS_FIELDS.each do |field|
    #   translations[field] = I18n.t("datagrid.columns.clients.#{field}")
    # end

    translations[key.to_sym] || ''
  end

  def family_header(key)
    translations = {
      name:                                     I18n.t('datagrid.columns.families.name'),
      id:                                       I18n.t('datagrid.columns.families.id'),
      code:                                     I18n.t('datagrid.columns.families.code'),
      family_type:                              I18n.t('datagrid.columns.families.family_type'),
      status:                                   I18n.t('datagrid.columns.families.status'),
      gender:                                   I18n.t('activerecord.attributes.family_member.gender'),
      date_of_birth:                            I18n.t('datagrid.columns.families.date_of_birth'),
      case_history:                             I18n.t('datagrid.columns.families.case_history'),
      address:                                  I18n.t('datagrid.columns.families.address'),
      significant_family_member_count:          I18n.t('datagrid.columns.families.significant_family_member_count'),
      male_children_count:                      I18n.t('datagrid.columns.families.male_children_count'),
      province_id:                              I18n.t('datagrid.columns.families.province'),
      district_id:                              I18n.t('datagrid.columns.families.district'),
      commune_id:                               I18n.t('datagrid.columns.families.commune'),
      village_id:                               I18n.t('datagrid.columns.families.village'),
      street:                                   I18n.t('datagrid.columns.families.street'),
      house:                                    I18n.t('datagrid.columns.families.house'),
      client_id:                                I18n.t('datagrid.columns.families.client'),
      dependable_income:                        I18n.t('datagrid.columns.families.dependable_income'),
      male_adult_count:                         I18n.t('datagrid.columns.families.male_adult_count'),
      household_income:                         I18n.t('datagrid.columns.families.household_income'),
      contract_date:                            I18n.t('datagrid.columns.families.contract_date'),
      caregiver_information:                    I18n.t('datagrid.columns.families.caregiver_information'),
      changelog:                                I18n.t('datagrid.columns.families.changelog'),
      manage:                                   I18n.t('datagrid.columns.families.manage'),
      female_children_count:                    I18n.t('datagrid.columns.families.female_children_count'),
      female_adult_count:                       I18n.t('datagrid.columns.families.female_adult_count'),
      case_workers:                             I18n.t('datagrid.columns.families.case_workers'),
      member_count:                             I18n.t('datagrid.columns.families.member_count')
    }
    translations[key.to_sym] || ''
  end

  def partner_header(key)
    translations = {
      name:                                     I18n.t('datagrid.columns.partners.name'),
      id:                                       I18n.t('datagrid.columns.partners.id'),
      contact_person_name:                      I18n.t('datagrid.columns.partners.contact_name'),
      contact_person_email:                     I18n.t('datagrid.columns.partners.contact_email'),
      contact_person_mobile:                    I18n.t('datagrid.columns.partners.contact_mobile'),
      address:                                  I18n.t('datagrid.columns.partners.address'),
      organization_type_id:                     I18n.t('datagrid.columns.partners.organization_type'),
      affiliation:                              I18n.t('datagrid.columns.partners.affiliation'),
      province_id:                              I18n.t('datagrid.columns.partners.province'),
      engagement:                               I18n.t('datagrid.columns.partners.engagement'),
      background:                               I18n.t('datagrid.columns.partners.background'),
      start_date:                               I18n.t('datagrid.columns.partners.start_date'),
    }
    translations[key.to_sym] || ''
  end

  def save_search_params(search_params)
    if search_params.dig(:client_advanced_search, :basic_rules).nil?
      report_builder = { client_advanced_search: { action_report_builder: '#builder' } }
      search_params.deep_merge!(report_builder)
    else
      json_rules = JSON.parse(search_params[:client_advanced_search][:basic_rules])
      rules = format_rule(json_rules)
      search_params[:client_advanced_search][:basic_rules] = rules.to_json
      report_builder = { client_advanced_search: { action_report_builder: '#builder' } }
      search_params.deep_merge!(report_builder)
    end
  end

  def custom_id_translation(type)
    @customer_id_setting ||= Setting.first
    if I18n.locale == :en || @customer_id_setting.country_name == 'lesotho'
      if type == 'custom_id1'
        @customer_id_setting.custom_id1_latin.present? ? @customer_id_setting.custom_id1_latin : I18n.t('clients.other_detail.custom_id_number1')
      else
        @customer_id_setting.custom_id2_latin.present? ? @customer_id_setting.custom_id2_latin : I18n.t('clients.other_detail.custom_id_number2')
      end
    else
      if type == 'custom_id1'
        @customer_id_setting.custom_id1_local.present? ? @customer_id_setting.custom_id1_local : I18n.t('clients.other_detail.custom_id_number1')
      else
        @customer_id_setting.custom_id2_local.present? ? @customer_id_setting.custom_id2_local : I18n.t('clients.other_detail.custom_id_number2')
      end
    end
  end
end
