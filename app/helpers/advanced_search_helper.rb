module AdvancedSearchHelper
  def set_value_custom_form
    if params[:client_advanced_search].present? && params[:client_advanced_search][:custom_form_selected].present?
      params[:client_advanced_search][:custom_form_selected]
    else
      ''
    end
  end

  def custom_form_disable_values
    if params[:client_advanced_search].present? && params[:client_advanced_search][:custom_form_disables].present?
      params[:client_advanced_search][:custom_form_disables]
    else
      '[]'
    end
  end

  def format_header(key)
    translations = {
      given_name: I18n.t('advanced_search.fields.given_name'),
      family_name: I18n.t('advanced_search.fields.family_name'),
      local_given_name: I18n.t('advanced_search.fields.local_given_name'),
      local_family_name: I18n.t('advanced_search.fields.local_family_name'),
      form_title: I18n.t('advanced_search.fields.form_title'),
      code: I18n.t('advanced_search.fields.code'),
      grade: I18n.t('advanced_search.fields.grade'),
      family_id: I18n.t('advanced_search.fields.family_id'),
      age: I18n.t('advanced_search.fields.age'),
      family: I18n.t('advanced_search.fields.family'),
      slug: I18n.t('advanced_search.fields.slug'),
      referral_phone: I18n.t('advanced_search.fields.referral_phone'),
      house_number: I18n.t('advanced_search.fields.house_number'),
      street_number: I18n.t('advanced_search.fields.street_number'),
      village: I18n.t('advanced_search.fields.village'),
      commune: I18n.t('advanced_search.fields.commune'),
      district: I18n.t('advanced_search.fields.district'),
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
      exit_kc_date: I18n.t('advanced_search.fields.exit_kc_date')
    }
    translations[key.to_sym] || ''
  end
end
