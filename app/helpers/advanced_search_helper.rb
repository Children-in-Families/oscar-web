module AdvancedSearchHelper
  def custom_form_values
    has_custom_form_selected = has_advanced_search? && advanced_search_params[:custom_form_selected].present?
    has_custom_form_selected ? eval(advanced_search_params[:custom_form_selected]) : []
  end

  def program_stream_values
    has_program_selected = has_advanced_search? && advanced_search_params[:program_selected].present?
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

  def has_advanced_search?
    params[:client_advanced_search].present?
  end

  def advanced_search_params
    params[:client_advanced_search]
  end

  def format_header(key)
    translations = {
      given_name: I18n.t('advanced_search.fields.given_name'),
      family_name: I18n.t('advanced_search.fields.family_name'),
      local_given_name: I18n.t('advanced_search.fields.local_given_name'),
      local_family_name: I18n.t('advanced_search.fields.local_family_name'),
      form_title: I18n.t('advanced_search.fields.form_title'),
      code: I18n.t('advanced_search.fields.code'),
      school_grade: I18n.t('advanced_search.fields.school_grade'),
      family_id: I18n.t('advanced_search.fields.family_id'),
      age: I18n.t('advanced_search.fields.age'),
      family: I18n.t('advanced_search.fields.family'),
      slug: I18n.t('advanced_search.fields.slug'),
      referral_phone: I18n.t('advanced_search.fields.referral_phone'),
      house_number: I18n.t('advanced_search.fields.house_number'),
      street_number: I18n.t('advanced_search.fields.street_number'),
      village: I18n.t('advanced_search.fields.village'),
      commune: I18n.t('advanced_search.fields.commune'),
      district_id: I18n.t('advanced_search.fields.district'),
      school_name: I18n.t('advanced_search.fields.school_name'),
      placement_date: I18n.t('advanced_search.fields.placement_start_date'),
      date_of_birth: I18n.t('advanced_search.fields.date_of_birth'),
      initial_referral_date: I18n.t('advanced_search.fields.initial_referral_date'),
      follow_up_date: I18n.t('advanced_search.fields.follow_up_date'),
      gender: I18n.t('advanced_search.fields.gender'),
      status: I18n.t('advanced_search.fields.status'),
      case_type: I18n.t('advanced_search.fields.case_type'),
      agency_name: I18n.t('advanced_search.fields.agency_name'),
      received_by_id: I18n.t('advanced_search.fields.received_by_id'),
      birth_province_id: I18n.t('advanced_search.fields.birth_province_id'),
      province_id: I18n.t('advanced_search.fields.province_id'),
      referral_source_id: I18n.t('advanced_search.fields.referral_source_id'),
      followed_up_by_id: I18n.t('advanced_search.fields.followed_up_by_id'),
      has_been_in_government_care: I18n.t('advanced_search.fields.has_been_in_government_care'),
      able_state: I18n.t('advanced_search.fields.able_state'),
      has_been_in_orphanage: I18n.t('advanced_search.fields.has_been_in_orphanage'),
      user_id: I18n.t('advanced_search.fields.user_id'),
      donor_id: I18n.t('advanced_search.fields.donor_id'),
      id_poor: I18n.t('advanced_search.fields.id_poor'),
      referred_to_ec: I18n.t('advanced_search.fields.referred_to_ec'),
      referred_to_kc: I18n.t('advanced_search.fields.referred_to_kc'),
      referred_to_fc: I18n.t('advanced_search.fields.referred_to_fc'),
      exit_ec_date: I18n.t('advanced_search.fields.exit_ec_date'),
      exit_fc_date: I18n.t('advanced_search.fields.exit_fc_date'),
      exit_kc_date: I18n.t('advanced_search.fields.exit_kc_date'),
      enrollment: I18n.t('advanced_search.fields.enrollment'),
      tracking: I18n.t('advanced_search.fields.tracking'),
      exit_program: I18n.t('advanced_search.fields.exit_program'),
      basic_fields: I18n.t('advanced_search.fields.basic_fields'),
      custom_form: I18n.t('advanced_search.fields.custom_form'),
      quantitative: I18n.t('advanced_search.fields.quantitative'),
      exit_date: I18n.t('advanced_search.fields.ngo_exit_date'),
      accepted_date: I18n.t('advanced_search.fields.ngo_accepted_date'),
      program_stream: I18n.t('advanced_search.fields.program_stream'),
      csi_domain_scores: I18n.t('advanced_search.fields.csi_domain_scores'),
      case_note_date: I18n.t('advanced_search.fields.case_note_date'),
      case_note_type: I18n.t('advanced_search.fields.case_note_type'),
      date_of_assessments: I18n.t('advanced_search.fields.date_of_assessments'),
      telephone_number: I18n.t('advanced_search.fields.telephone_number')
    }
    translations[key.to_sym] || ''
  end
end
