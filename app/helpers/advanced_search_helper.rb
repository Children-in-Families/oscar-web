module AdvancedSearchHelper
  include ClientsHelper
  include FamiliesHelper
  include CommunityHelper

  def custom_form_values(report_builder = '#builder')
    has_custom_form_selected = has_advanced_search? && advanced_search_params[:custom_form_selected].present? && (advanced_search_params[:action_report_builder].present? ? report_builder == advanced_search_params[:action_report_builder] : true)
    has_custom_form_selected ? eval(advanced_search_params[:custom_form_selected]) : []
  end

  def program_stream_values(report_builder = '#builder')
    # has_program_selected = has_advanced_search? && advanced_search_params[:program_selected].present? && report_builder == advanced_search_params[:action_report_builder]
    has_program_selected = has_advanced_search? && advanced_search_params[:program_selected].present? && (advanced_search_params[:action_report_builder].present? ? report_builder == advanced_search_params[:action_report_builder] : true)
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
    params[:client_advanced_search].present? || params[:family_advanced_search].present? || params[:partner_advanced_search].present? || params[:community_advanced_search].present?
  end

  def advanced_search_params
    params[:client_advanced_search] || params[:family_advanced_search] || params[:partner_advanced_search] || params[:community_advanced_search]
  end

  def format_header(key)
    translations = {
      given_name: I18n.t('advanced_search.fields.given_name'),
      family_name: I18n.t('advanced_search.fields.family_name'),
      local_given_name: "#{I18n.t('advanced_search.fields.local_given_name')} #{country_scope_label_translation}",
      local_family_name: "#{I18n.t('advanced_search.fields.local_family_name')} #{country_scope_label_translation}",
      carer: I18n.t('advanced_search.fields.carer'),
      carer_name: I18n.t('activerecord.attributes.carer.name'),
      carer_phone: I18n.t('activerecord.attributes.carer.phone'),
      carer_email: I18n.t('activerecord.attributes.carer.email'),
      carer_relationship_to_client: I18n.t('datagrid.columns.clients.carer_relationship_to_client'),
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
      suburb: I18n.t('advanced_search.fields.suburb'),
      description_house_landmark: I18n.t('advanced_search.fields.description_house_landmark'),
      directions: I18n.t('advanced_search.fields.directions'),
      street_line1: I18n.t('advanced_search.fields.street_line1'),
      street_line2: I18n.t('advanced_search.fields.street_line2'),
      phone_owner: I18n.t('advanced_search.fields.phone_owner'),
      plot: I18n.t('advanced_search.fields.plot'),
      road: I18n.t('advanced_search.fields.road'),
      postal_code: I18n.t('advanced_search.fields.postal_code'),
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
      referral_source_id: I18n.t('advanced_search.fields.referral_source_id'),
      followed_up_by_id: I18n.t('advanced_search.fields.followed_up_by_id'),
      has_been_in_government_care: I18n.t('advanced_search.fields.has_been_in_government_care'),
      able_state: I18n.t('advanced_search.fields.able_state'),
      has_been_in_orphanage: I18n.t('advanced_search.fields.has_been_in_orphanage'),
      user_id: I18n.t('advanced_search.fields.user_id'),
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
      referee: I18n.t('advanced_search.fields.referee'),
      referee_name: I18n.t('advanced_search.fields.referee_name'),
      referee_phone: I18n.t('advanced_search.fields.referee_phone'),
      referee_email: I18n.t('advanced_search.fields.referee_email'),
      referee_relationship: I18n.t('advanced_search.fields.referee_relationship'),
      time_in_cps: I18n.t('advanced_search.fields.time_in_cps'),
      time_in_ngo: I18n.t('advanced_search.fields.time_in_ngo'),
      assessment_number: I18n.t('advanced_search.fields.assessment_number', assessment: I18n.t('clients.show.assessment')),
      assessment_completed_date: I18n.t('advanced_search.fields.assessment_completed_date', assessment: I18n.t('clients.show.assessment')),
      month_number: I18n.t('advanced_search.fields.month_number'),
      custom_csi_group: I18n.t('advanced_search.fields.custom_csi_group'),
      referral_source_category_id: I18n.t('advanced_search.fields.referral_source_category_id'),
      type_of_service:  I18n.t('advanced_search.fields.type_of_service'),
      hotline: I18n.t('datagrid.columns.calls.hotline'),
      active_clients: I18n.t('advanced_search.fields.active_clients'),
      care_plan: I18n.t('advanced_search.fields.care_plan'),
      **overdue_translations,
      **address_translation
    }

    translations[key.to_sym] || ''
  end

  def family_header(key)
    translations = map_family_field_labels
    translations[key.to_sym] || ''
  end

  def community_header(key)
    translations = {
      initial_referral_date:                    I18n.t('advanced_search.fields.initial_referral_date'),
      name:                                     I18n.t('activerecord.attributes.community.name'),
      name_en:                                  I18n.t('activerecord.attributes.community.name_en'),
      status:                                   I18n.t('activerecord.attributes.community.status'),
      formed_date:                              I18n.t('activerecord.attributes.community.formed_date'),
      gender:                                   I18n.t('activerecord.attributes.community.gender'),
      id:                                       I18n.t('activerecord.attributes.community.formed_date'),
      initial_referral_date:                    I18n.t('activerecord.attributes.community.initial_referral_date'),
      phone_number:                             I18n.t('activerecord.attributes.community.phone_number'),
      received_by_id:                           I18n.t('advanced_search.fields.received_by_id'),
      relevant_information:                     I18n.t('activerecord.attributes.community.relevant_information'),
      representative_name:                      I18n.t('activerecord.attributes.community.representative_name'),
      referral_source_category_id:              I18n.t('activerecord.attributes.community.referral_source_category_id'),
      referral_source_id:                       I18n.t('activerecord.attributes.community.referral_source_id'),
      role:                                     I18n.t('activerecord.attributes.community.role'),
      **community_member_columns,
      **address_translation
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
      engagement:                               I18n.t('datagrid.columns.partners.engagement'),
      background:                               I18n.t('datagrid.columns.partners.background'),
      start_date:                               I18n.t('datagrid.columns.partners.start_date'),
      **address_translation
    }
    translations[key.to_sym] || ''
  end

  def address_translation
    translations = {}
    ['province', 'district', 'commune', 'village', 'birth_province', 'province_id', 'district_id', 'commune_id'].each do |key_translation|
      translations[key_translation.to_sym] = FieldSetting.find_by(name: key_translation).try(:label) || I18n.t("advanced_search.fields.#{key_translation}")
    end
    translations['province_id'.to_sym] = FieldSetting.find_by(name: 'province_id').try(:label) || I18n.t('advanced_search.fields.province_id')
    translations['district_id'.to_sym] = FieldSetting.find_by(name: 'district_id').try(:label) || I18n.t('datagrid.columns.clients.district')
    translations['commune_id'.to_sym] = FieldSetting.find_by(name: 'commune_id').try(:label) || I18n.t('datagrid.columns.clients.commune')
    translations['village_id'.to_sym] = FieldSetting.find_by(name: 'village_id').try(:label) || I18n.t('datagrid.columns.clients.village')
    translations['birth_province_id'.to_sym] = FieldSetting.find_by(name: 'birth_province').try(:label) || I18n.t('datagrid.columns.clients.birth_province')
    translations
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

  def user_select_options
    User.non_strategic_overviewers.order(:first_name, :last_name).map { |user| { user.id.to_s => user.name } }
  end

  def concern_translation(hotline_field)
    if %W(concern_province_id concern_district_id concern_commune_id concern_village_id).include? hotline_field
      address_translation[hotline_field.gsub('concern_', '').to_sym]
    else
      I18n.t("datagrid.columns.clients.#{hotline_field}")
    end
  end

  def date_query(klass_name, objects, association, field_name)
    result_objects = objects.joins(association).distinct
    case @operator
    when 'equal'
      results = result_objects.where("date(#{field_name}) = ?", @value.to_date)
    when 'not_equal'
      results = klass_name.includes(association).references(association).where("date(#{field_name}) != ? OR #{field} IS NULL", @value.to_date)
    when 'less'
      results = result_objects.where("date(#{field_name}) < ?", @value.to_date)
    when 'less_or_equal'
      results = result_objects.where("date(#{field_name}) <= ?", @value.to_date)
    when 'greater'
      results = result_objects.where("date(#{field_name}) > ?", @value.to_date)
    when 'greater_or_equal'
      results = result_objects.where("date(#{field_name}) >= ?", @value.to_date)
    when 'between'
      results = result_objects.where("date(#{field_name}) BETWEEN ? AND ? ", @value[0].to_date, @value[1].to_date)
    when 'is_empty'
      results = klass_name.includes(association).references(association).where("#{field_name} IS NULL")
    when 'is_not_empty'
      results = result_objects.where("#{field_name} IS NOT NULL")
    end
    results.ids
  end
end
