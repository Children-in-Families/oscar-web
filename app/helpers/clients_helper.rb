module ClientsHelper
  include RiskAssessmentHelper

  def client_form_data
    {
      translation: rails_i18n_translations, inlineHelpTranslation: JSON.parse(I18n.t('inline_help').to_json),
      internationalReferredClient: international_referred_client, selectedCountry: selected_country,
      client: {
        referral_id: params[:referral_id],
        client: @client, ratanak_achievement_program_staff_client_ids: @client.ratanak_achievement_program_staff_client_ids,
        user_ids: @client.user_ids, quantitative_case_ids: @client.quantitative_case_ids, agency_ids: @client.agency_ids,
        donor_ids: @client.donor_ids, isTestClient: current_setting.test_client?, isForTesting: @client.for_testing?
      },
      client_quantitative_free_text_cases: get_or_build_client_quantitative_free_text_cases,
      family_member: (@client.family_member || {}), moSAVYOfficials: @client.mo_savy_officials,
      referee: @referee.as_json(methods: [:existing_referree]), carer: @carer, users: case_workers_option(@client.id),
      referralSourceCategory: @referral_source_category, referralSource: ReferralSource.all, birthProvinces: @birth_provinces,
      currentProvinces: @current_provinces || get_address('province'), cities: @cities, districts: @districts.presence || get_address('district'),
      subDistricts: @subdistricts, communes: @communes.presence || get_address('commune'), villages: @villages.presence || get_address('village'),
      currentStates: @states, currentTownships: @townships, refereeTownships: @referee_townships, carerTownships: @carer_townships, refereeCities: @referee_cities,
      refereeDistricts: @referee_districts, refereeSubdistricts: @referee_subdistricts, refereeCommunes: @referee_communes,
      refereeVillages: @referee_villages, carerCities: @carer_cities, carerDistricts: @carer_districts, carerSubdistricts: @carer_subdistricts, carerCommunes: @carer_communes,
      carerVillages: @carer_villages, donors: @donors, agencies: @agencies,
      quantitativeType: QuantitativeType.cach_by_visible_on('client'), quantitativeCase: QuantitativeCase.cache_all,
      ratePoor: [
        t('clients.level').values, Client::CLIENT_LEVELS
      ].transpose,
      schoolGrade: [
        Client::GRADES, t('advanced_search.fields.school_grade_list').values
      ].transpose,
      families: @families, refereeRelationships: @referee_relationships,
      clientRelationships: @client_relationships, callerRelationships: @caller_relationships,
      addressTypes: @address_types, phoneOwners: @phone_owners, fieldsVisibility: fields_visibility,
      requiredFields: required_legal_docs, current_organization: JSON.parse(current_organization.to_json),
      brc_address: get_address_json, maritalStatuses: Client::MARITAL_STATUSES, nationalities: Client::NATIONALITIES,
      ethnicities: Client::ETHNICITY, traffickingTypes: Client::TRAFFICKING_TYPES, brc_islands: Client::BRC_BRANCHES,
      brc_resident_types: Client::BRC_RESIDENT_TYPES, brc_presented_ids: Client::BRC_PRESENTED_IDS,
      brc_prefered_langs: Client::BRC_PREFERED_LANGS, customId1: custom_id_translation('custom_id1'),
      customId2: custom_id_translation('custom_id2'), referees: Referee.where(anonymous: false),
      protectionConcerns: I18n.locale == :km ? protection_concern_list_local : protection_concern_list,
      historyOfHarms: history_of_harms, historyOfHighRiskBehaviours: history_of_high_risk_behaviours,
      reasonForFamilySeparations: reason_for_family_separations, historyOfDisabilities: history_of_disabilities,
      isRiskAssessmentEnabled: current_setting.enabled_risk_assessment,
      riskAssessment: {
        has_assessment_level_of_risk: client_has_assessment_level_of_risk?(@client),
        **@risk_assessment.try(:attributes).try(:symbolize_keys) || {},
        labels: {
          **I18n.t('risk_assessments._attr'),
          **I18n.t('tasks')
        },
        tasks_attributes: @risk_assessment.try(:tasks).presence || [{ name: '', expected_date: '' }]
      },
      customData: @custom_data&.fields || [],
      clientCustomFields: @client_custom_data_properties || {}
    }
  end

  def client_has_assessment_level_of_risk?(client)
    client.assessments.client_risk_assessments.any?
  end

  def get_or_build_client_quantitative_free_text_cases
    QuantitativeType.where(field_type: 'free_text').map do |qtt|
      @client.client_quantitative_free_text_cases.find_or_initialize_by(quantitative_type_id: qtt.id)
    end
  end

  def xeditable?(object = nil)
    return true if object.class.name != 'Client'

    client = object.instance_of?(::ClientDecorator) ? object.client : object
    can?(:manage, client) || can?(:edit, client) || can?(:rud, client) ? true : false
  end

  def user(user, editable_input = false)
    if !editable_input
      if can? :read, User
        link_to user.name, user_path(user) if user.present?
      elsif user.present?
        user.name
      end
    else
      if user.present? && can?(:read, User)
        link_to user_path(user) do
          fa_icon 'external-link'
        end
      end
    end
  end

  def link_to_client_show(client)
    link_to client.name, client_path(client) if client
  end

  def order_case_worker(client)
    client.users.distinct.sort
  end

  def partner(partner)
    if can? :manage, :all
      link_to partner.name, partner_path(partner)
    else
      partner.name
    end
  end

  def family(family)
    family_name = family.name.present? ? family.name : 'Unknown'
    if can? :manage, :all
      link_to family_name, family_path(family)
    else
      family_name
    end
  end

  def rails_i18n_translations
    # Change slice inputs to adapt your need
    return {} unless I18n.backend.send(:translations).present?
    return {} unless I18n.backend.send(:translations).key?(I18n.locale)

    translations = I18n.backend.send(:translations)[I18n.locale].slice(
      :clients,
      :activerecord,
      :default_client_fields
    )

    if current_organization.short_name != 'brc' && I18n.locale.to_s == 'en'
      translations[:clients][:form][:local_given_name] += " #{country_scope_label_translation}" if translations[:clients][:form][:local_given_name].exclude?(country_scope_label_translation)
      translations[:clients][:form][:local_family_name] += " #{country_scope_label_translation}" if translations[:clients][:form][:local_family_name].exclude?(country_scope_label_translation)
    end

    translations
  end

  # Add klass_name_name for readability
  def fields_visibility
    result = field_settings.each_with_object({}) do |field_setting, output|
      output[field_setting.name] = output["#{field_setting.klass_name}_#{field_setting.name}"] = policy(Client).show?(field_setting.name)
    end

    result[:brc_client_address] = result[:client_brc_client_address] = policy(Client).brc_client_address?
    result[:brc_client_other_address] = result[:client_brc_client_other_address] = policy(Client).brc_client_other_address?
    result[:show_legal_doc] = result[:client_show_legal_doc] = policy(Client).show_legal_doc?
    result[:school_information] = result[:client_school_information] = policy(Client).client_school_information?
    result[:stackholder_contacts] = result[:client_stackholder_contacts] = policy(Client).client_stackholder_contacts?
    result[:pickup_information] = result[:client_pickup_information] = policy(Client).client_pickup_information?

    result
  end

  def required_legal_docs
    result = field_settings.each_with_object({}) do |field_setting, output|
      field_mapping = Client::LEGAL_DOC_MAPPING[field_setting.name.to_sym]

      if field_mapping.present? && field_setting.required?
        output[field_setting.name] = true
      end
    end

    {
      fields: result,
      mapping: Client::LEGAL_DOC_MAPPING
    }
  end

  def report_options(title, yaxis_title)
    {
      library: {
        legend: {
          verticalAlign: 'top',
          y: 30
        },
        tooltip: {
          shared: true,
          xDateFormat: '%b %Y'
        },
        title: {
          text: title
        },
        xAxis: {
          dateTimeLabelFormats: {
            month: '%b %Y'
          },
          tickmarkPlacement: 'on'
        },
        yAxis: {
          allowDecimals: false,
          title: {
            text: yaxis_title
          }
        }
      }
    }
  end

  def label_translations(address_translation = {})
    labels = {
      family_type: I18n.t('datagrid.columns.families.family_type'),
      legal_documents: I18n.t('clients.show.legal_documents'),
      passport_number: I18n.t('datagrid.columns.clients.passport_number'),
      national_id_number: I18n.t('datagrid.columns.clients.national_id_number'),
      marital_status: I18n.t('datagrid.columns.clients.marital_status'),
      nationality: I18n.t('datagrid.columns.clients.nationality'),
      ethnicity: I18n.t('datagrid.columns.clients.ethnicity'),
      location_of_concern: I18n.t('datagrid.columns.clients.location_of_concern'),
      type_of_trafficking: I18n.t('datagrid.columns.clients.type_of_trafficking'),
      education_background: I18n.t('datagrid.columns.clients.education_background'),
      department: I18n.t('datagrid.columns.clients.department'),
      slug: I18n.t('datagrid.columns.clients.id'),
      kid_id: custom_id_translation('custom_id2'),
      code: custom_id_translation('custom_id1'),
      age: I18n.t('datagrid.columns.clients.age'),
      presented_id: I18n.t('datagrid.columns.clients.presented_id'),
      id_number: I18n.t('datagrid.columns.clients.id_number'),
      legacy_brcs_id: I18n.t('datagrid.columns.clients.legacy_brcs_id'),
      whatsapp: I18n.t('datagrid.columns.clients.whatsapp'),
      preferred_language: I18n.t('datagrid.columns.clients.preferred_language'),
      other_phone_number: I18n.t('datagrid.columns.clients.other_phone_number'),
      brsc_branch: I18n.t('datagrid.columns.clients.brsc_branch'),
      current_island: I18n.t('datagrid.columns.current_address', column: I18n.t('datagrid.columns.clients.current_island')),
      current_street: I18n.t('datagrid.columns.current_address', column: I18n.t('datagrid.columns.clients.current_street')),
      current_po_box: I18n.t('datagrid.columns.current_address', column: I18n.t('datagrid.columns.clients.current_po_box')),
      current_settlement: I18n.t('datagrid.columns.current_address', column: I18n.t('datagrid.columns.clients.current_settlement')),
      current_resident_own_or_rent: I18n.t('datagrid.columns.current_address', column: I18n.t('datagrid.columns.clients.current_resident_own_or_rent')),
      current_household_type: I18n.t('datagrid.columns.current_address', column: I18n.t('datagrid.columns.clients.current_household_type')),
      island2: I18n.t('datagrid.columns.other_address', column: I18n.t('datagrid.columns.clients.island2')),
      street2: I18n.t('datagrid.columns.other_address', column: I18n.t('datagrid.columns.clients.street2')),
      po_box2: I18n.t('datagrid.columns.other_address', column: I18n.t('datagrid.columns.clients.po_box2')),
      settlement2: I18n.t('datagrid.columns.other_address', column: I18n.t('datagrid.columns.clients.settlement2')),
      resident_own_or_rent2: I18n.t('datagrid.columns.other_address', column: I18n.t('datagrid.columns.clients.resident_own_or_rent2')),
      household_type2: I18n.t('datagrid.columns.other_address', column: I18n.t('datagrid.columns.clients.household_type2')),
      given_name: I18n.t('datagrid.columns.clients.given_name'),
      family_name: I18n.t('datagrid.columns.clients.family_name'),
      local_given_name: I18n.t('datagrid.columns.clients.local_given_name'),
      local_family_name: I18n.t('datagrid.columns.clients.local_family_name'),
      gender: I18n.t('datagrid.columns.clients.gender'),
      date_of_birth: I18n.t('datagrid.columns.clients.date_of_birth'),
      status: I18n.t('datagrid.columns.clients.status'),
      received_by_id: I18n.t('datagrid.columns.clients.received_by'),
      followed_up_by_id: I18n.t('datagrid.columns.clients.follow_up_by'),
      initial_referral_date: I18n.t('datagrid.columns.clients.initial_referral_date'),
      referral_phone: I18n.t('datagrid.columns.clients.referral_phone'),
      referral_source_id: I18n.t('datagrid.columns.clients.referral_source'),
      follow_up_date: I18n.t('datagrid.columns.clients.follow_up_date'),
      agencies_name: I18n.t('datagrid.columns.clients.agencies_involved'),
      donor_name: I18n.t('datagrid.columns.clients.donor'),
      current_address: I18n.t('datagrid.columns.clients.current_address'),
      house_number: I18n.t('datagrid.columns.clients.house_number'),
      street_number: I18n.t('datagrid.columns.clients.street_number'),
      school_name: I18n.t('datagrid.columns.clients.school_name'),
      school_grade: I18n.t('datagrid.columns.clients.school_grade'),
      able_state: I18n.t('datagrid.columns.clients.able_state'),
      has_been_in_orphanage: I18n.t('datagrid.columns.clients.has_been_in_orphanage'),
      has_been_in_government_care: I18n.t('datagrid.columns.clients.has_been_in_government_care'),
      relevant_referral_information: I18n.t('datagrid.columns.clients.relevant_referral_information'),
      user_id: I18n.t('datagrid.columns.clients.case_worker'),
      state: I18n.t('datagrid.columns.clients.state'),
      family_id: I18n.t('datagrid.columns.clients.family_id'),
      family: I18n.t('datagrid.columns.clients.family'),
      any_assessments: I18n.t('datagrid.columns.clients.assessments'),
      case_note_date: I18n.t('datagrid.columns.clients.case_note_date'),
      case_note_type: I18n.t('datagrid.columns.clients.case_note_type'),
      assessment_created_at: I18n.t('datagrid.columns.clients.assessment_created_at', assessment: I18n.t('clients.show.assessment')),
      date_of_assessments: I18n.t('datagrid.columns.clients.date_of_assessments', assessment: I18n.t('clients.show.assessment')),
      completed_date: I18n.t('datagrid.columns.calls.assessment_completed_date', assessment: I18n.t('clients.show.assessment')),
      date_of_referral: I18n.t('datagrid.columns.clients.date_of_referral'),
      date_of_custom_assessments: I18n.t('datagrid.columns.clients.date_of_custom_assessments', assessment: I18n.t('clients.show.assessment')),
      custom_assessment_created_at: I18n.t('datagrid.columns.clients.custom_assessment_created_at', assessment: I18n.t('clients.show.assessment')),
      changelog: I18n.t('datagrid.columns.clients.changelog'),
      live_with: I18n.t('datagrid.columns.clients.live_with'),
      program_streams: I18n.t('datagrid.columns.clients.program_streams'),
      program_enrollment_date: I18n.t('datagrid.columns.clients.program_enrollment_date'),
      program_exit_date: I18n.t('datagrid.columns.clients.program_exit_date'),
      accepted_date: I18n.t('datagrid.columns.clients.ngo_accepted_date'),
      telephone_number: I18n.t('datagrid.columns.clients.telephone_number'),
      exit_date: I18n.t('datagrid.columns.clients.ngo_exit_date'),
      created_at: I18n.t('datagrid.columns.clients.created_at'),
      created_by: I18n.t('datagrid.columns.clients.created_by'),
      referred_to: I18n.t('datagrid.columns.clients.referred_to'),
      referred_from: I18n.t('datagrid.columns.clients.referred_from'),
      referral_source_category_id: I18n.t('datagrid.columns.clients.referral_source_category'),
      type_of_service: I18n.t('datagrid.columns.type_of_service'),
      hotline: I18n.t('datagrid.columns.calls.hotline'),
      care_plan_date: I18n.t('care_plans.care_plan_date'),
      care_plan_completed_date: I18n.t('datagrid.columns.clients.care_plan_completed_date'),
      care_plan_count: I18n.t('datagrid.columns.clients.care_plan_count'),
      **overdue_translations,
      **Client::HOTLINE_FIELDS.map { |field| [field.to_sym, I18n.t("datagrid.columns.clients.#{field}")] }.to_h,
      **legal_doc_fields.map { |field| [field.to_sym, I18n.t("clients.show.#{field}")] }.to_h,
      **@address_translation,
      **custom_assessment_field_traslation_mapping
    }

    lable_translation_uderscore.map { |k, v| [k.to_s.gsub(/(\_)$/, '').to_sym, v] }.to_h.merge(labels)
  end

  def lable_translation_uderscore
    {
      marital_status_: I18n.t('datagrid.columns.clients.marital_status'),
      nationality_: I18n.t('datagrid.columns.clients.nationality'),
      ethnicity_: I18n.t('datagrid.columns.clients.ethnicity'),
      location_of_concern_: I18n.t('datagrid.columns.clients.location_of_concern'),
      type_of_trafficking_: I18n.t('datagrid.columns.clients.type_of_trafficking'),
      education_background_: I18n.t('datagrid.columns.clients.education_background'),
      department_: I18n.t('datagrid.columns.clients.department'),
      presented_id_: I18n.t('datagrid.columns.clients.presented_id'),
      id_number_: I18n.t('datagrid.columns.clients.id_number'),
      legacy_brcs_id_: I18n.t('datagrid.columns.clients.legacy_brcs_id'),
      whatsapp_: I18n.t('datagrid.columns.clients.whatsapp'),
      preferred_language_: I18n.t('datagrid.columns.clients.preferred_language'),
      other_phone_number_: I18n.t('datagrid.columns.clients.other_phone_number'),
      brsc_branch_: I18n.t('datagrid.columns.clients.brsc_branch'),
      current_island_: I18n.t('datagrid.columns.current_address', column: I18n.t('datagrid.columns.clients.current_island')),
      current_street_: I18n.t('datagrid.columns.current_address', column: I18n.t('datagrid.columns.clients.current_street')),
      current_po_box_: I18n.t('datagrid.columns.current_address', column: I18n.t('datagrid.columns.clients.current_po_box')),
      current_settlement_: I18n.t('datagrid.columns.current_address', column: I18n.t('datagrid.columns.clients.current_settlement')),
      current_resident_own_or_rent_: I18n.t('datagrid.columns.current_address', column: I18n.t('datagrid.columns.clients.current_resident_own_or_rent')),
      current_household_type_: I18n.t('datagrid.columns.current_address', column: I18n.t('datagrid.columns.clients.current_household_type')),
      island2_: I18n.t('datagrid.columns.other_address', column: I18n.t('datagrid.columns.clients.island2')),
      street2_: I18n.t('datagrid.columns.other_address', column: I18n.t('datagrid.columns.clients.street2')),
      po_box2_: I18n.t('datagrid.columns.other_address', column: I18n.t('datagrid.columns.clients.po_box2')),
      settlement2_: I18n.t('datagrid.columns.other_address', column: I18n.t('datagrid.columns.clients.settlement2')),
      resident_own_or_rent2_: I18n.t('datagrid.columns.other_address', column: I18n.t('datagrid.columns.clients.resident_own_or_rent2')),
      household_type2_: I18n.t('datagrid.columns.other_address', column: I18n.t('datagrid.columns.clients.household_type2')),
      exit_reasons_: I18n.t('datagrid.columns.clients.exit_reasons'),
      exit_circumstance_: I18n.t('datagrid.columns.clients.exit_circumstance'),
      other_info_of_exit_: I18n.t('datagrid.columns.clients.other_info_of_exit'),
      exit_note_: I18n.t('datagrid.columns.clients.exit_note'),
      what3words_: I18n.t('datagrid.columns.clients.what3words'),
      name_of_referee_: I18n.t('datagrid.columns.clients.name_of_referee'),
      rated_for_id_poor_: I18n.t('datagrid.columns.clients.rated_for_id_poor'),
      main_school_contact_: I18n.t('datagrid.columns.clients.main_school_contact'),
      program_streams_: I18n.t('datagrid.columns.clients.program_streams'),
      given_name_: I18n.t('datagrid.columns.clients.given_name'),
      family_name_: I18n.t('datagrid.columns.clients.family_name'),
      local_given_name_: local_name_label,
      local_family_name_: local_name_label(:local_family_name),
      gender_: I18n.t('datagrid.columns.clients.gender'),
      date_of_birth_: I18n.t('datagrid.columns.clients.date_of_birth'),
      status_: I18n.t('datagrid.columns.clients.status'),
      initial_referral_date_: I18n.t('datagrid.columns.clients.initial_referral_date'),
      referral_phone_: I18n.t('datagrid.columns.clients.referral_phone'),
      received_by_id_: I18n.t('datagrid.columns.clients.received_by'),
      referral_source_id_: I18n.t('datagrid.columns.clients.referral_source'),
      followed_up_by_id_: I18n.t('datagrid.columns.clients.follow_up_by'),
      follow_up_date_: I18n.t('datagrid.columns.clients.follow_up_date'),
      agencies_name_: I18n.t('datagrid.columns.clients.agencies_involved'),
      donor_name_: I18n.t('datagrid.columns.clients.donor'),
      current_address_: I18n.t('datagrid.columns.clients.current_address'),
      house_number_: I18n.t('datagrid.columns.clients.house_number'),
      street_number_: I18n.t('datagrid.columns.clients.street_number'),
      school_name_: I18n.t('datagrid.columns.clients.school_name'),
      school_grade_: I18n.t('datagrid.columns.clients.school_grade'),
      has_been_in_orphanage_: I18n.t('datagrid.columns.clients.has_been_in_orphanage'),
      has_been_in_government_care_: I18n.t('datagrid.columns.clients.has_been_in_government_care'),
      relevant_referral_information_: I18n.t('datagrid.columns.clients.relevant_referral_information'),
      user_id_: I18n.t('datagrid.columns.clients.case_worker'),
      state_: I18n.t('datagrid.columns.clients.state'),
      accepted_date_: I18n.t('datagrid.columns.clients.ngo_accepted_date'),
      exit_date_: I18n.t('datagrid.columns.clients.ngo_exit_date'),
      history_of_disability_and_or_illness_: I18n.t('datagrid.columns.clients.history_of_disability_and_or_illness'),
      history_of_harm_: I18n.t('datagrid.columns.clients.history_of_harm'),
      history_of_high_risk_behaviours_: I18n.t('datagrid.columns.clients.history_of_high_risk_behaviours'),
      reason_for_family_separation_: I18n.t('datagrid.columns.clients.reason_for_family_separation'),
      rejected_note_: I18n.t('datagrid.columns.clients.rejected_note'),
      family_: I18n.t('datagrid.columns.clients.placements.family'),
      code_: custom_id_translation('custom_id1'),
      age_: I18n.t('datagrid.columns.clients.age'),
      slug_: I18n.t('datagrid.columns.clients.id'),
      kid_id_: custom_id_translation('custom_id2'),
      family_id_: I18n.t('datagrid.columns.families.code'),
      case_note_created_at_: I18n.t('datagrid.columns.case_note_created_at'),
      case_note_date_: I18n.t('datagrid.columns.clients.case_note_date'),
      case_note_type_: I18n.t('datagrid.columns.clients.case_note_type'),
      assessment_created_at_: I18n.t('datagrid.columns.clients.assessment_created_at', assessment: I18n.t('clients.show.assessment')),
      date_of_assessments_: I18n.t('datagrid.columns.clients.date_of_assessments', assessment: I18n.t('clients.show.assessment')),
      date_of_referral_: I18n.t('datagrid.columns.clients.date_of_referral'),
      all_csi_assessments_: I18n.t('datagrid.columns.clients.all_csi_assessments'),
      date_of_custom_assessments_: I18n.t('datagrid.columns.clients.date_of_custom_assessments', assessment: I18n.t('clients.show.assessment')),
      custom_assessment_created_at_: I18n.t('datagrid.columns.clients.custom_assessment_created_at', assessment: I18n.t('clients.show.assessment')),
      all_custom_csi_assessments_: I18n.t('datagrid.columns.clients.all_custom_csi_assessments', assessment: I18n.t('clients.show.assessment')),
      manage_: I18n.t('datagrid.columns.clients.manage'),
      changelog_: I18n.t('datagrid.columns.changelog'),
      subdistrict_: I18n.t('datagrid.columns.clients.subdistrict'),
      township_: I18n.t('datagrid.columns.clients.township'),
      postal_code_: I18n.t('datagrid.columns.clients.postal_code'),
      road_: I18n.t('datagrid.columns.clients.road'),
      plot_: I18n.t('datagrid.columns.clients.plot'),
      street_line1_: I18n.t('datagrid.columns.clients.street_line1'),
      street_line2_: I18n.t('datagrid.columns.clients.street_line2'),
      suburb_: I18n.t('datagrid.columns.clients.suburb'),
      directions_: I18n.t('datagrid.columns.clients.directions'),
      description_house_landmark_: I18n.t('datagrid.columns.clients.description_house_landmark'),
      created_at_: I18n.t('datagrid.columns.clients.created_at'),
      created_by_: I18n.t('datagrid.columns.clients.created_by'),
      referred_to_: I18n.t('datagrid.columns.clients.referred_to'),
      referred_from_: I18n.t('datagrid.columns.clients.referred_from'),
      time_in_ngo_: I18n.t('datagrid.columns.clients.time_in_ngo'),
      time_in_cps_: I18n.t('datagrid.columns.clients.time_in_cps'),
      referral_source_category_id_: I18n.t('datagrid.columns.clients.referral_source_category'),
      type_of_service_: I18n.t('datagrid.columns.type_of_service'),
      assessment_completed_date_: I18n.t('datagrid.columns.calls.assessment_completed_date', assessment: I18n.t('clients.show.assessment')),
      hotline_call_: I18n.t('datagrid.columns.calls.hotline_call'),
      indirect_beneficiaries_: I18n.t('datagrid.columns.clients.indirect_beneficiaries'),
      carer_name_: I18n.t('activerecord.attributes.carer.name'),
      carer_phone_: I18n.t('activerecord.attributes.carer.phone'),
      carer_email_: I18n.t('activerecord.attributes.carer.email'),
      arrival_at_: I18n.t('clients.form.arrival_at'),
      flight_nb_: I18n.t('clients.form.flight_nb'),
      ratanak_achievement_program_staff_client_ids_: I18n.t('clients.form.ratanak_achievement_program_staff_client_ids'),
      mosavy_official_: I18n.t('clients.form.mosavy_official'),
      carer_relationship_to_client_: I18n.t('datagrid.columns.clients.carer_relationship_to_client'),
      province_id_: FieldSetting.cache_by_name_klass_name_instance('current_province', 'client') || I18n.t('datagrid.columns.clients.current_province'),
      birth_province_id_: FieldSetting.cache_by_name_klass_name_instance('birth_province', 'client') || I18n.t('datagrid.columns.clients.birth_province'),
      **custom_data_fields,
      **overdue_translations.map { |k, v| ["#{k}_".to_sym, v] }.to_h
    }
  end

  def custom_data_fields
    (CustomData.first.try(:fields) || []).map { |field| ["#{field['name']}_".to_sym, field['label']] }.to_h
  end

  def columns_visibility(column)
    label_column = label_translations.map { |k, v| [k.to_s.to_sym, v] }.to_h

    Client::STACKHOLDER_CONTACTS_FIELDS.each do |field|
      label_column[field] = I18n.t("datagrid.columns.clients.#{field}")
    end
    label_tag "#{column}_", label_column[column.to_sym]
  end

  def overdue_translations
    {
      has_overdue_assessment: I18n.t('datagrid.form.has_overdue_assessment', assessment: I18n.t('clients.show.assessment')),
      has_overdue_forms: I18n.t('datagrid.form.has_overdue_forms'),
      has_overdue_task: I18n.t('datagrid.form.has_overdue_task'),
      no_case_note: I18n.t('datagrid.form.no_case_note')
    }
  end

  def custom_assessment_field_traslation_mapping
    {
      custom_assessment: I18n.t('datagrid.columns.clients.custom_assessment', assessment: I18n.t('clients.show.assessment')),
      custom_completed_date: I18n.t('datagrid.columns.clients.assessment_custom_completed_date', assessment: I18n.t('clients.show.assessment')),
      custom_assessment_created_at: I18n.t('datagrid.columns.clients.custom_assessment_created_at', assessment: I18n.t('clients.show.assessment'))
    }
  end

  def local_name_label(name_type = :local_given_name)
    custom_field = FieldSetting.cache_by_name(name_type.to_s, 'client')
    label = I18n.t("datagrid.columns.clients.#{name_type}")
    label = "#{label} #{country_scope_label_translation}" if custom_field.blank?
    label
  end

  def ec_manageable
    current_user.admin? || current_user.case_worker? || current_user.manager?
  end

  def fc_manageable
    current_user.admin? || current_user.case_worker? || current_user.manager?
  end

  def kc_manageable
    current_user.admin? || current_user.case_worker? || current_user.manager?
  end

  def client_custom_fields_list(object)
    content_tag(:ul, class: 'client-custom-fields-list') do
      if params[:data] == 'recent'
        object.custom_field_properties.order(created_at: :desc).first.try(:custom_field).try(:form_title)
      else
        object.custom_fields.uniq.each do |obj|
          concat(content_tag(:li, obj.form_title))
        end
      end
    end
  end

  def concern_merged_address(client)
    current_address = []
    current_address << "#{t('datagrid.columns.clients.concern_house')} #{client.concern_house}" if client.concern_house.present?
    current_address << "#{t('datagrid.columns.clients.concern_street')} #{client.concern_street}" if client.concern_street.present?

    if I18n.locale.to_s == 'km'
      current_address << "#{t('datagrid.columns.clients.concern_village_id')} #{client.concern_village.name_kh}" if client.concern_village.present?
      current_address << "#{t('datagrid.columns.clients.concern_commune_id')} #{client.concern_commune.name_kh}" if client.concern_commune.present?
      current_address << client.concern_district.name.split(' / ').first if client.concern_district.present?
      current_address << client.concern_province.name.split(' / ').first if client.concern_province.present?
    else
      current_address << "#{t('datagrid.columns.clients.concern_village_id')} #{client.concern_village.name_en}" if client.concern_village.present?
      current_address << "#{t('datagrid.columns.clients.concern_commune_id')} #{client.concern_commune.name_en}" if client.concern_commune.present?
      current_address << client.concern_district.name.split(' / ').last if client.concern_district.present?
      current_address << client.concern_province.name.split(' / ').last if client.concern_province.present?
    end
    current_address << selected_country.titleize
  end

  def format_array_value(value)
    value.is_a?(Array) ? check_is_array_date?(value.reject(&:empty?).gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>').gsub('&qoute;', '"')).join(' , ') : check_is_string_date?(value.gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>').gsub('&qoute;', '"'))
  end

  def check_is_array_date?(properties)
    properties.is_a?(Array) && properties.flatten.all? { |value| DateTime.strptime(value, '%Y-%m-%d') rescue nil } ? properties.map { |value| date_format(value.to_date) } : properties
  end

  def check_is_string_date?(property)
    (DateTime.strptime(property, '%Y-%m-%d') rescue nil).present? ? property.to_date : property
  end

  def format_properties_value(value)
    value.is_a?(Array) ? check_is_array_date?(value.delete_if(&:empty?).map { |c| c.gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>').gsub('&qoute;', '"') }).join(' , ') : check_is_string_date?(value.gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>').gsub('&qoute;', '"'))
  end

  def field_not_blank?(value)
    value.is_a?(Array) ? value.delete_if(&:empty?).present? : value.present?
  end

  def form_builder_format_key(value)
    value.downcase.parameterize('_')
  end

  def form_builder_format(value)
    value.split('__').last
  end

  def form_builder_format_header(value)
    entities = { formbuilder: 'Custom form', exitprogram: 'Exit program', tracking: 'Tracking', enrollment: 'Enrollment', enrollmentdate: 'Enrollment', exitprogramdate: 'Exit program' }
    key_word = value.first
    entity = entities[key_word.to_sym]
    value = value - [key_word]
    result = value << entity
    result.join(' | ')
  end

  def group_entity_by(value)
    value.group_by { |field| field.split('_').first }
  end

  def format_class_header(value)
    values = value.split('|')
    name = values.first.strip
    label = values.last.strip
    keyword = "#{name} #{label}"
    keyword.downcase.parameterize.gsub('-', '__')
  end

  def field_not_render(field)
    field.split('_').first
  end

  def all_csi_assessment_lists(object)
    content_tag(:ul) do
      if params[:data] == 'recent'
        object.latest_record.try(:basic_info)
      else
        object.each do |assessment|
          concat(content_tag(:li, assessment.basic_info))
        end
      end
    end
  end

  def check_params_no_case_note
    true if params.dig(:client_grid, :no_case_note) == 'Yes'
  end

  def check_params_has_over_forms
    true if params.dig(:client_grid, :overdue_forms) == 'Yes'
  end

  def check_params_has_over_assessment
    true if params.dig(:client_grid, :assessments_due_to) == 'Overdue'
  end

  def check_params_has_overdue_task
    true if params.dig(:client_grid, :overdue_task) == 'Overdue'
  end

  def status_exited?(value)
    value == 'Exited'
  end

  def default_columns_visibility(column)
    label_column = label_translations.map { |k, v| ["#{k}_".to_sym, v] }.to_h

    (Client::HOTLINE_FIELDS + Call::FIELDS).each do |field_name|
      label_column["#{field_name}_".to_sym] = I18n.t("datagrid.columns.clients.#{field_name}")
    end

    Domain.order_by_identity.each do |domain|
      identity = domain.identity
      field = domain.convert_identity
      label_column = label_column.merge!("#{field}_": identity)
    end
    QuantitativeType.joins(:quantitative_cases).where('quantitative_types.visible_on LIKE ?', '%client%').uniq.each do |quantitative_type|
      field = quantitative_type.name
      label_column = label_column.merge!("#{field}_": quantitative_type.name)
    end
    label_column[column.to_sym]
  end

  def quantitative_type_readable?(quantitative_type_id)
    current_user.admin? || current_user.strategic_overviewer? || (@quantitative_type_readable_ids && @quantitative_type_readable_ids.include?(quantitative_type_id))
  end

  def quantitative_type_cannot_editable?(quantitative_type_id)
    return false if current_user.admin?
    return true if @quantitative_type_editable_ids.exclude?(quantitative_type_id)
  end

  def header_classes(grid, column)
    klasses = datagrid_column_classes(grid, column).split(' ')
    return klasses.first if klasses.include?('form-builder')
    klasses.last
  end

  def client_advanced_search_data(object, rule)
    @data = {}
    return object unless $param_rules.present?

    @data = $param_rules['basic_rules'].is_a?(String) ? JSON.parse($param_rules['basic_rules']).with_indifferent_access : $param_rules['basic_rules']
    @data[:rules].reject { |h| h[:id] != rule }.map { |value| [value[:id], value[:operator], value[:value]] }
  end

  def mapping_query_string(object, hashes, association, rule)
    param_values = []
    sql_string = []
    hashes[rule].each do |value|
      value.each do |key, values|
        case key
        when 'equal'
          sql_string << "#{association} = ?"
          param_values << values
        when 'not_equal'
          sql_string << "#{association} != ?"
          param_values << values
        when 'is_empty'
          sql_string << "#{association} IS NULL"
        when 'is_not_empty'
          sql_string << "#{association} IS NOT NULL"
        else
          object
        end
      end
    end
    { sql_string: sql_string, values: param_values }
  end

  def program_stream_name(object, rule)
    properties_field = 'client_enrollment_trackings.properties'
    basic_rules = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
    return object if basic_rules.nil?

    basic_rules = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
    results = mapping_form_builder_param_value(basic_rules, rule)
    query_string = get_query_string(results, rule, properties_field)
    default_value_param = params['all_values']
    if default_value_param
      object
    elsif rule == 'tracking'
      object.joins(:client_enrollment_trackings).where(query_string.reject(&:blank?).join(" #{basic_rules[:condition]} ")).distinct
    elsif rule == 'active_program_stream'
      mew_query_string = query_string.reject(&:blank?).join(" #{basic_rules[:condition]} ")
      program_stream_ids = mew_query_string&.scan(/program_streams\.id = (\d+)/)&.flatten || []
      if program_stream_ids.size >= 2
        sql_partial = mew_query_string.gsub(/program_streams\.id = \d+/, "program_streams.id IN (#{program_stream_ids.join(', ')})")
        object.includes(client: :program_streams).where(sql_partial).references(:program_streams).distinct
      else
        object.includes(client: :program_streams).where(query_string.reject(&:blank?).join(" #{basic_rules[:condition]} ")).references(:program_streams).distinct
      end
    else
      object
    end
  end

  def mapping_sub_query_array(object, association, rule)
    sub_query_array = []
    if @data[:rules]
      sub_rule_index = @data[:rules].index { |param| param.key?(:condition) }
      if sub_rule_index.present?
        sub_hashes = Hash.new { |h, k| h[k] = [] }
        sub_results = @data[:rules][sub_rule_index]
        sub_result_hash = sub_results[:rules].reject { |h| h[:id] != rule }.map { |value| [value[:id], value[:operator], value[:value]] }
        sub_result_hash.each { |k, o, v| sub_hashes[k] << { o => v } }
        sub_sql_hash = mapping_query_string(object, sub_hashes, association, rule)
        sub_query_array = mapping_query_string_with_query_value(sub_sql_hash, sub_results[:condition])
      end
    end
    sub_query_array
  end

  def case_note_query(object, rule)
    return object unless params[:client_advanced_search].present? && params[:client_advanced_search][:basic_rules].present?

    data = JSON.parse(params[:client_advanced_search][:basic_rules]).with_indifferent_access
    result1 = mapping_param_value(data, 'case_note_date')
    result2 = mapping_param_value(data, 'case_note_type')

    default_value_param = params['all_values']

    if default_value_param == 'case_note_date'
      return case_note_date_all_value(object, data, result2, rule, default_value_param)
    elsif default_value_param == 'case_note_type'
      return case_note_type_all_value(object, data, result1, rule, default_value_param)
    end

    case_note_date_hashes = mapping_query_result(result1)
    case_note_type_hashes = Hash.new { |h, k| h[k] = [] }
    result2.each { |k, o, v| case_note_type_hashes[k] << { o => v } }

    sub_case_note_date_query, sub_case_note_type_query = sub_query_results(object, data)

    sql_case_note_date_hash = mapping_query_date(object, case_note_date_hashes, 'case_notes.meeting_date')
    sql_case_note_type_hash = mapping_query_string(object, case_note_type_hashes, 'case_notes.interaction_type', 'case_note_type')

    case_note_date_query = mapping_query_string_with_query_value(sql_case_note_date_hash, data[:condition])
    case_note_type_query = mapping_query_string_with_query_value(sql_case_note_type_hash, data[:condition])

    if case_note_date_query.present? && case_note_type_query.blank?
      object = object.where(case_note_date_query).where(sub_case_note_date_query)
    elsif case_note_type_query.present? && case_note_date_query.blank?
      object = object.where(case_note_type_query).where(sub_case_note_type_query)
    elsif data[:condition] == 'AND'
      object = object.where(case_note_date_query).where(case_note_type_query).where(sub_case_note_type_query).where(sub_case_note_date_query)
    elsif sub_case_note_type_query.first.blank? && sub_case_note_date_query.first.blank?
      object = case_note_query_results(object, case_note_date_query, case_note_type_query)
    elsif sub_case_note_date_query.first.present? && sub_case_note_type_query.first.blank?
      object = case_note_query_results(object, case_note_date_query, case_note_type_query).or(object.where(sub_case_note_date_query))
    elsif sub_case_note_type_query.first.present? && sub_case_note_date_query.first.blank?
      object = case_note_query_results(object, case_note_date_query, case_note_type_query).or(object.where(sub_case_note_type_query))
    else
      object = case_note_query_results(object, case_note_date_query, case_note_type_query).or(object.where(sub_case_note_type_query)).or(object.where(sub_case_note_date_query))
    end
    object.present? ? object : []
  end

  def form_builder_query(object, form_type, field_name, properties_field = nil)
    return object if params['all_values'].present?

    properties_field = properties_field.present? ? properties_field : 'client_enrollment_trackings.properties'

    selected_program_stream = $param_rules['program_selected'].presence ? JSON.parse($param_rules['program_selected']) : []
    basic_rules = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
    basic_rules = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
    results = mapping_form_builder_param_value(basic_rules, form_type, field_name)
    return object if results.flatten.blank?

    query_string = get_query_string(results, form_type, properties_field)
    if form_type == 'formbuilder'
      object.where(query_string.reject(&:blank?).join(" #{basic_rules['condition']} "))
    else
      object.joins(:client_enrollment).where(client_enrollments: { program_stream_id: selected_program_stream }).where(query_string.reject(&:blank?).join(" #{basic_rules['condition']} "))
    end
  end

  def family_form_builder_query(object, form_type, field_name, properties_field = nil)
    return object if $param_rules['all_values'].present?
    properties_field = properties_field.present? ? properties_field : 'enrollment_trackings.properties'

    selected_program_stream = $param_rules['program_selected'].presence ? JSON.parse($param_rules['program_selected']) : []
    basic_rules = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
    basic_rules = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
    results = mapping_form_builder_param_value(basic_rules, form_type)

    return object if results.flatten.blank?

    query_string = get_query_string(results, form_type, properties_field)
    if form_type == 'formbuilder'
      properties_result = object.where(query_string.reject(&:blank?).join(" #{basic_rules['condition']} "))
    else
      properties_result = object.joins(:enrollment).where(enrollments: { program_stream_id: selected_program_stream }).where(query_string.reject(&:blank?).join(" #{basic_rules['condition']} "))
    end
  end

  def case_note_query_results(object, case_note_date_query, case_note_type_query)
    results = []
    if case_note_date_query.first.present? && case_note_type_query.first.blank?
      results = object.where(case_note_date_query)
    elsif case_note_date_query.first.blank? && case_note_type_query.first.present?
      results = object.where(case_note_type_query)
    else
      results = object.where(case_note_date_query).or(object.where(case_note_type_query))
    end
    results
  end

  def sub_query_results(object, data)
    sub_case_note_date_query = ['']
    sub_case_note_type_query = ['']
    if data[:rules]
      sub_rule_index = data[:rules].index { |param| param.key?(:condition) }
      if sub_rule_index.present?
        sub_case_note_date_results = data[:rules][sub_rule_index]
        sub_case_note_date_result_hash = mapping_param_value(sub_case_note_date_results, 'case_note_date')
        sub_case_note_date_hashes = mapping_query_result(sub_case_note_date_result_hash)
        sub_case_note_date_sql_hash = mapping_query_date(object, sub_case_note_date_hashes, 'case_notes.meeting_date')
        sub_case_note_date_query = mapping_query_string_with_query_value(sub_case_note_date_sql_hash, sub_case_note_date_results[:condition])

        sub_case_note_type_hashes = Hash.new { |h, k| h[k] = [] }
        sub_case_note_type_results = data[:rules][sub_rule_index]
        sub_case_note_type_result_hash = mapping_param_value(sub_case_note_type_results, 'case_note_type')
        sub_case_note_type_result_hash.each { |k, o, v| sub_case_note_type_hashes[k] << { o => v } }
        sub_case_note_type_sql_hash = mapping_query_string(object, sub_case_note_type_hashes, 'case_notes.interaction_type', 'case_note_type')
        sub_case_note_type_query = mapping_query_string_with_query_value(sub_case_note_type_sql_hash, data[:condition])
      end
    end
    [sub_case_note_date_query, sub_case_note_type_query]
  end

  def case_note_date_all_value(object, data, results, rule, default_value_param)
    return if default_value_param.blank?
    if rule == default_value_param
      return object
    else
      sub_case_note_type_query = ['']
      case_note_type_hashes = Hash.new { |h, k| h[k] = [] }
      results.each { |k, o, v| case_note_type_hashes[k] << { o => v } }
      sql_case_note_type_hash = mapping_query_string(object, case_note_type_hashes, 'case_notes.interaction_type', 'case_note_type')
      case_note_type_query = mapping_query_string_with_query_value(sql_case_note_type_hash, data[:condition])
      sub_case_note_type_query = sub_query_results(object, data).last
      if data[:condition] == 'AND'
        if sub_case_note_type_query.first.blank?
          object = object.where(case_note_type_query)
        else
          object = object.where(case_note_type_query).where(sub_case_note_type_query)
        end
      else
        if sub_case_note_type_query.first.blank?
          object = object.where(case_note_type_query)
        else
          object = object.where(case_note_type_query).or(object.where(sub_case_note_type_query))
        end
      end
      return object
    end
  end

  def case_note_type_all_value(object, data, results, rule, default_value_param)
    return if default_value_param.blank?

    sub_case_note_date_query = ['']
    case_note_date_hashes = mapping_query_result(results)
    sql_case_note_date_hash = mapping_query_date(object, case_note_date_hashes, 'case_notes.meeting_date')
    case_note_date_query = mapping_query_string_with_query_value(sql_case_note_date_hash, data[:condition])
    sub_case_note_date_query = sub_query_results(object, data).first
    if data[:condition] == 'AND'
      if sub_case_note_date_query.first.blank?
        object = object.where(case_note_date_query)
      else
        object = object.where(case_note_date_query).where(sub_case_note_date_query)
      end
    else
      if sub_case_note_date_query.first.blank?
        object = object.where(case_note_date_query)
      else
        object = object.where(case_note_date_query).or(object.where(sub_case_note_date_query))
      end
    end
    return object
  end

  def mapping_param_value(data, rule)
    data[:rules].reject { |h| h[:id] != rule }.map { |value| [value[:id], value[:operator], value[:value]] }
  end

  def mapping_form_builder_param_value(data, form_type, field_name = nil, data_mapping = [])
    rule_array = []
    data[:rules].each_with_index do |h, _|
      mapping_form_builder_param_value(h, form_type, field_name, data_mapping) if h.key?(:rules)

      if field_name.nil?
        next if h[:id]&.scan(form_type).blank?
      elsif h[:id] != field_name
        next
      end

      h[:condition] = data[:condition]
      rule_array << h
    end
    data_mapping << rule_array
  end

  def date_filter(object, rule)
    query_array = []
    sub_query_array = []
    field_name = ''
    results = client_advanced_search_data(object, rule)
    return object if return_default_filter(object, rule, results)

    klass_name = { exit_date: 'exit_ngos', accepted_date: 'enter_ngos', meeting_date: 'case_notes', case_note_type: 'case_notes', created_at: 'assessments', completed_date: 'assessments', date_of_referral: 'referrals', care_plan_completed_date: 'care_plans', care_plan_date: 'care_plans' }.with_indifferent_access

    if rule == 'case_note_date'
      field_name = 'meeting_date'
    elsif rule == 'completed_date'
      field_name = 'completed_date'
    elsif rule.in? ['assessment_created_at', 'custom_assessment_created_at', 'care_plan_completed_date']
      field_name = 'created_at'
    elsif rule.in?(['date_of_assessments', 'date_of_custom_assessments'])
      klass_name = { date_of_assessments: 'assessments', date_of_custom_assessments: 'assessments', assessment_date: 'assessments' }
      field_name = 'assessment_date'
    elsif rule[/^(exitprogramdate)/i].present? || object.class.to_s[/^(leaveprogram)/i]
      klass_name.merge!(rule => 'leave_programs')
      field_name = 'exit_date'
    elsif rule[/^(enrollmentdate)/i].present?
      klass_name.merge!(rule => 'client_enrollments')
      field_name = 'enrollment_date'
    else
      field_name = rule
    end

    relation = rule[/^(enrollmentdate)|^(exitprogramdate)|^(care_plan_completed_date)/i] ? "#{klass_name[rule]}.#{field_name}" : "#{klass_name[field_name.to_sym]}.#{field_name}"
    relation = object.first&.class&.name == 'Enrollment' ? "enrollments.#{field_name}" : relation

    hashes = mapping_query_result(results)
    sql_hash = mapping_query_date(object, hashes, relation)

    if @data[:rules]
      sub_rule_index = @data[:rules].index { |param| param.key?(:condition) }
      if sub_rule_index.present?
        sub_results = @data[:rules][sub_rule_index]
        if sub_results[:rules].present?
          sub_result_hash = sub_results[:rules].reject { |h| h[:id] != rule }.map { |value| [value[:id], value[:operator], value[:value]] }
          sub_hashes = mapping_query_result(sub_result_hash)
          sub_sql_hash = mapping_query_date(object, sub_hashes, relation)
          sub_query_array = mapping_query_string_with_query_value(sub_sql_hash, sub_results[:condition])
        end
      end
    end

    query_array = mapping_query_string_with_query_value(sql_hash, @data[:condition])

    if rule == 'date_of_assessments'
      sql_string = object.where(query_array).where(default: true).where(sub_query_array)
    elsif rule == 'date_of_custom_assessments' || rule == 'custom_assessment_created_at'
      sql_string = object.where(query_array).where(default: false).where(sub_query_array)
    else
      if object.is_a?(Array)
        sql_string = object.first.class.where(id: object.map(&:id)).where(query_array).where(sub_query_array)
      else
        sql_string = object.where(id: object.map(&:id)).where(query_array).where(sub_query_array)
      end
    end

    sql_string.present? && sql_hash[:sql_string].present? ? sql_string : []
  end

  def header_counter(grid, column)
    return column.header.truncate(65) if grid.class.to_s != 'ClientGrid' || @clients_by_user.blank?
    count = 0
    class_name = header_classes(grid, column)
    class_name = class_name == 'call-field' ? column.name.to_s : class_name

    if Client::HEADER_COUNTS.include?(class_name) || class_name[/^(enrollmentdate)/i] || class_name[/^(exitprogramdate)/i] || class_name[/^(formbuilder)/i] || class_name[/^(tracking)/i]
      association = "#{class_name}_count"
      klass_name = { exit_date: 'exit_ngos', accepted_date: 'enter_ngos', case_note_date: 'case_notes', case_note_type: 'case_notes', date_of_assessments: 'assessments', date_of_custom_assessments: 'assessments', formbuilder__Client: 'custom_field_properties' }

      if class_name[/^(exitprogramdate)/i].present? || class_name[/^(leaveprogram)/i]
        klass = 'leave_programs'
      elsif class_name[/^(enrollmentdate)/i].present? || column.header == I18n.t('datagrid.columns.clients.program_streams')
        klass = 'client_enrollments'
      else
        klass = klass_name[class_name.to_sym]
      end

      format_field_value = column.name.to_s.split('__').last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
      fields = column.name.to_s.gsub('&qoute;', '"').split('__')

      if class_name[/^(programexitdate|exitprogramdate)/i].present?
        ids = @clients_by_user.map { |client| client.client_enrollments.inactive.ids }.flatten.uniq
        if $param_rules.nil?
          object = LeaveProgram.joins(:program_stream).where(program_streams: { name: column.header.split('|').first.squish }, leave_programs: { client_enrollment_id: ids })
          count += date_filter(object, class_name).flatten.count
        else
          basic_rules = $param_rules['basic_rules']
          basic_rules = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
          results = mapping_exit_program_date_param_value(basic_rules)
          query_string = get_exit_program_date_query_string(results)
          object = LeaveProgram.joins(:program_stream).where(program_streams: { name: column.header.split('|').first.squish }, leave_programs: { client_enrollment_id: ids }).where(query_string)
        end
        count = object.distinct.count
      else
        @clients_by_user.each do |client|
          if class_name == 'case_note_date'
            count += case_note_count(client).count
          elsif class_name == 'case_note_type'
            count += case_note_count(client).count
          elsif column.header == I18n.t('datagrid.columns.clients.program_streams')
            class_name = 'active_program_stream'
            program_stream_name_active = program_stream_name(client.send(klass.to_sym).active, class_name)
            if program_stream_name_active.present?
              count += program_stream_name(client.send(klass.to_sym).active, class_name).count
            else
              count += client.send(klass.to_sym).active.count
            end
          elsif class_name[/^(enrollmentdate)/i].present?
            data_filter = date_filter(client.client_enrollments.joins(:program_stream).where(program_streams: { name: column.header.split('|').first.squish }), "#{class_name} Date")
            count += data_filter.map(&:enrollment_date).flatten.count if data_filter.present?
          elsif class_name[/^(date_of_assessments)/i].present?
            if params['all_values'] == class_name
              data_filter = date_filter(client.assessments.defaults, "#{class_name}")
            else
              data_filter = date_filter(client.assessments.defaults, "#{class_name}")
            end

            count += data_filter.present? ? data_filter.flatten.count : 0
          elsif class_name[/^(date_of_custom_assessments|custom_assessment_created_at)/i].present?
            if params['all_values'] == class_name
              data_filter = date_filter(client.assessments.customs, "#{class_name}")
            else
              data_filter = date_filter(client.assessments.customs, "#{class_name}")
              count += data_filter.flatten.count if data_filter.present?
            end
          elsif class_name[/^(formbuilder)/i].present?
            if fields.last == 'Has This Form'
              count += client.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Client' }).count
            else
              custom_field_id = client.custom_fields.cached_client_custom_field_find_by(client, fields.second)
              properties = form_builder_query(client.custom_field_properties.where(custom_field_id: custom_field_id), fields.first, column.name.to_s.gsub('&qoute;', '"'), 'custom_field_properties.properties').properties_by(format_field_value)
              count += property_filter(properties, format_field_value).size
            end
          elsif class_name[/^(tracking)/i]
            ids = client.client_enrollments.ids
            client_enrollment_trackings = ClientEnrollmentTracking.joins(:tracking).where(trackings: { name: column.name.to_s.split('__').third }, client_enrollment_trackings: { client_enrollment_id: ids })
            properties = form_builder_query(client_enrollment_trackings, 'tracking', column.name.to_s.gsub('&qoute;', '"')).properties_by(format_field_value)
            count += property_filter(properties, format_field_value).size
          elsif class_name == 'quantitative-type'
            quantitative_type_values = client.quantitative_cases.joins(:quantitative_type).where(quantitative_types: { name: column.header }).pluck(:value)
            quantitative_type_values = property_filter(quantitative_type_values, column.header.split('|').third.try(:strip) || column.header.strip)
            count += quantitative_type_values.count
          elsif class_name == 'type_of_service'
            type_of_services = map_type_of_services(client)
            count += type_of_services.count
          elsif class_name == 'date_of_call'
            count += client.calls.distinct.count
          elsif class_name == 'indirect_beneficiaries'
            count += client.indirect_beneficiaries
          else
            count += date_filter(client.send(klass.to_sym), class_name).count
          end
        end
      end

      if count > 0 && class_name != 'case_note_type'
        class_name = class_name =~ /^(formbuilder)/i ? column.name.to_s : class_name
        link_all = params['all_values'] != class_name ? button_to('All', advanced_search_clients_path, params: params.merge(all_values: class_name), remote: false, form_class: 'all-values') : ''
        [column.header.truncate(65),
         content_tag(:span, count, class: 'label label-info'),
         link_all].join(' ').html_safe
      else
        column.header.truncate(65)
      end
    else
      column.header.truncate(65)
    end
  end

  def family_counter
    return unless controller_name == 'clients'
    count = @results.joins('INNER JOIN families on families.id = clients.current_family_id').distinct.count('clients.current_family_id')
    content_tag(:span, count, class: 'label label-info')
  end

  def care_plan_counter
    return unless controller_name == 'clients' || controller_name == 'families'
    count = @results.joins(:care_plans).distinct.count
    content_tag(:span, count, class: 'label label-info')
  end

  def case_note_count(client)
    results = []
    @basic_rules = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
    if @basic_rules.present?
      basic_rules = @basic_rules.is_a?(Hash) ? @basic_rules : JSON.parse(@basic_rules).with_indifferent_access
      results = mapping_allowed_param_value(basic_rules, ['case_note_date', 'case_note_type'], data_mapping = [])
      query_string = get_any_query_string(results, 'case_notes')
      client.case_notes.where(query_string)
    else
      client.case_notes
    end
  end

  def case_history_label(value)
    label = case value.class.table_name
            when 'enter_ngos' then I18n.t('accepted_date')
            when 'exit_ngos' then I18n.t('clients.case_history_detail.exit_date')
            when 'client_enrollments', 'enrollments' then "#{value.program_stream.try(:name)} Entry"
            when 'leave_programs' then "#{value.program_stream.name} Exit"
            when 'clients', 'families' then I18n.t('.initial_referral_date')
            when 'referrals'
              if value.referred_to == current_organization.short_name
                "#{t('.internal_referral')}: #{value.referred_from_ngo}"
              else
                "#{t('.external_referral')}: #{value.referred_to_ngo}"
              end
            end
    label
  end

  def international_referred_client
    params[:referral_id].present? && @client.country_origin != selected_country
  end

  def mapping_query_result(results)
    hashes = values = Hash.new { |h, k| h[k] = [] }
    results.each do |k, o, v|
      values[o] << v
      hashes[k] << values
    end

    hashes.keys.each do |value|
      arr = hashes[value]
      hashes.delete(value)
      hashes[value] << arr.uniq
    end
    hashes
  end

  def mapping_query_date(object, hashes, relation)
    sql_string = []
    param_values = []
    hashes.keys.each do |key|
      values = hashes[key].flatten
      case key
      when 'between'
        sql_string << "date(#{relation}) BETWEEN ? AND ?"
        param_values << values.first
        param_values << values.last
      when 'greater_or_equal'
        sql_string << "date(#{relation}) >= ?"
        param_values << values
      when 'greater'
        sql_string << "date(#{relation}) > ?"
        param_values << values
      when 'less'
        sql_string << "date(#{relation}) < ?"
        param_values << values
      when 'less_or_equal'
        sql_string << "date(#{relation}) <= ?"
        param_values << values
      when 'not_equal'
        sql_string << "date(#{relation}) NOT IN (?)"
        param_values << values
      when 'equal'
        sql_string << "date(#{relation}) IN (?)"
        param_values << values
      when 'is_empty'
        sql_string << "date(#{relation}) IS NULL"
      when 'is_not_empty'
        sql_string << "date(#{relation}) IS NOT NULL"
      else
        object
      end
    end

    { sql_string: sql_string, values: param_values }
  end

  def mapping_query_string_with_query_value(sql_hash, condition)
    query_array = []
    query_array << sql_hash[:sql_string].join(" #{condition} ")
    sql_hash[:values].map { |v| query_array << v }
    query_array
  end

  def return_default_filter(object, rule, results)
    rule[/^(#{$param_rules && $param_rules['all_values']})/i].present? || object.blank? || results.blank? || results.class.name[/activerecord/i].present?
  end

  def editable_case_worker_options
    @editable_case_worker_options ||= case_workers_option(@client.id, true)
  end

  def case_workers_option(client_id, editable_input = false)
    users = @users.includes(:incomplete_tasks).to_a
    users.map do |user|
      tasks = user.incomplete_tasks.select { |task| task.client_id == client_id }

      if !editable_input
        if tasks.any?
          [user.name, user.id, { locked: 'locked' }]
        else
          [user.name, user.id]
        end
      else
        if tasks.any?
          { text: user.name, value: user.id, locked: 'locked' }
        else
          { text: user.name, value: user.id }
        end
      end
    end
  end

  def case_history_links(case_history, case_history_name)
    case case_history_name
    when 'client_enrollments'
      link_to edit_client_client_enrollment_path(@client, case_history, program_stream_id: case_history.program_stream_id) do
        content_tag :div, class: 'btn btn-outline btn-success btn-xs' do
          fa_icon('pencil')
        end
      end
    when 'leave_programs'
      enrollment = @client.client_enrollments.find(case_history.client_enrollment_id)
      link_to edit_client_client_enrollment_leave_program_path(@client, enrollment, case_history) do
        content_tag :div, class: 'btn btn-outline btn-success btn-xs' do
          fa_icon('pencil')
        end
      end
    end
  end

  def render_case_history(case_history, case_history_name)
    case case_history_name
    when 'enter_ngos'
      render 'client/enter_ngos/edit_form', client: @client, enter_ngo: case_history
    when 'exit_ngos'
      render 'client/exit_ngos/edit_form', client: @client, exit_ngo: case_history
    end
  end

  def date_format(date)
    date.strftime('%d %B %Y') if date.present?
  end

  def country_scope_label_translation
    return '' if Setting.first.try(:country_name) == 'nepal'
    if I18n.locale.to_s == 'en'
      country_name = Setting.first.try(:country_name)
      case country_name
      when 'cambodia' then '(Khmer)'
      when 'indonesia' then '(Bahasa)'
      when 'myanmar' then '(Burmese)'
      when 'lesotho' then '(Sesotho)'
      when 'thailand' then '(Thai)'
      when 'uganda' then '(Swahili)'
      else
        '(Unknown)'
      end
    end
  end

  def client_alias_id
    current_organization.short_name == 'fts' ? @client.code : @client.slug
  end

  def date_condition_filter(rule, properties)
    if rule && properties.present?
      case rule[:operator]
      when 'equal'
        properties = properties.select { |value| value.to_date == rule[:value].to_date }
      when 'not_equal'
        properties = properties.select { |value| value.to_date != rule[:value].to_date }
      when 'less'
        properties = properties.select { |value| value.to_date < rule[:value].to_date }
      when 'less_or_equal'
        properties = properties.select { |value| value.to_date <= rule[:value].to_date }
      when 'greater'
        properties = properties.select { |value| value.to_date > rule[:value].to_date }
      when 'greater_or_equal'
        properties = properties.select { |value| value.to_date >= rule[:value].to_date }
      when 'is_empty'
        properties = []
      when 'is_not_empty'
        properties
      when 'between'
        properties = if properties.is_a?(Array)
                       properties.select do |value|
                         value.to_s[/\d{4}-\d{2}-\d{2}/].present? && value.to_date >= rule[:value].first.to_date && value.to_date <= rule[:value].last.to_date
                       end
                     else
                       [properties].flatten.compact
                     end
      end
    end
    properties || []
  end

  def property_filter(properties, field_name)
    results = []
    rule = get_rule(params, field_name)
    if rule.presence && rule.dig(:type) == 'date'
      results = date_condition_filter(rule, properties)
    elsif rule.presence && rule[:input] == 'select'
      results = select_condition_filter(rule, properties.flatten)
    elsif rule.presence
      results = string_condition_filter(rule, properties.flatten)
    end
    results.presence || properties
  end

  def string_condition_filter(rule, properties)
    case rule[:operator]
    when 'equal'
      properties = rule[:type] != 'integer' ? properties.select { |value| value == rule[:value].strip } : properties.select { |value| value.to_i == rule[:value] }
    when 'not_equal'
      properties = rule[:type] != 'integer' ? properties.select { |value| value != rule[:value].strip } : properties.select { |value| value.to_i != rule[:value] }
    when 'less'
      properties = rule[:type] != 'integer' ? properties.select { |value| value < rule[:value].strip } : properties.select { |value| value.to_i < rule[:value] }
    when 'less_or_equal'
      properties = rule[:type] != 'integer' ? properties.select { |value| value <= rule[:value].strip } : properties.select { |value| value.to_i <= rule[:value] }
    when 'greater'
      properties = rule[:type] != 'integer' ? properties.select { |value| value > rule[:value].strip } : properties.select { |value| value.to_i > rule[:value] }
    when 'greater_or_equal'
      properties = rule[:type] != 'integer' ? properties.select { |value| value >= rule[:value].strip } : properties.select { |value| value.to_i >= rule[:value] }
    when 'contains'
      properties.include?(rule[:value].strip)
    when 'not_contains'
      properties.exclude?(rule[:value].strip)
    when 'is_empty'
      properties = []
    when 'is_not_empty'
      properties
    when 'between'
      properties = rule[:type] != 'integer' ? properties.select { |value| value.to_i >= rule[:value].first.strip && value.to_i <= rule[:value].last.strip } : properties.select { |value| value.to_i >= rule[:value].first && value.to_i <= rule[:value].last }
    end
    properties
  end

  def select_condition_filter(rule, properties)
    case rule[:operator]
    when 'equal'
      properties = properties.select do |value|
        if rule[:data][:values].is_a?(Hash)
          value == rule[:data][:values][rule[:value].to_sym]
        else
          value == rule[:data][:values].map { |hash| hash[rule[:value].to_sym] }.compact.first
        end
      end
    when 'not_equal'
      properties = properties.select { |value| value != rule[:data][:values].map { |hash| hash[rule[:value].to_sym] }.compact.first }
    when 'is_empty'
      properties = []
    when 'is_not_empty'
      properties
    end
    properties
  end

  def get_rule(params, field)
    return unless params.dig('client_advanced_search').present? && params.dig('client_advanced_search', 'basic_rules').present?
    base_rules = eval params.dig('client_advanced_search', 'basic_rules')
    rules = base_rules.dig(:rules) if base_rules.presence

    index = find_rules_index(rules, field) if rules.presence

    rule = rules[index] if index.presence
  end

  def find_rules_index(rules, field)
    index = rules.index do |rule|
      if rule.has_key?(:rules)
        find_rules_index(rule[:rules], field)
      else
        rule[:field].strip == field
      end
    end
  end

  def group_client_associations
    [*@assessments, *@case_notes, *@tasks, *@client_enrollment_leave_programs, *@client_enrollment_trackings, *@client_enrollments, *@case_histories, *@custom_field_properties, *@calls].group_by do |association|
      class_name = association.class.name.downcase
      if class_name == 'clientenrollment' || class_name == 'leaveprogram' || class_name == 'casenote'
        created_date = association.created_at
        date_field = if class_name == 'clientenrollment'
                       association.enrollment_date
                     elsif class_name == 'leaveprogram'
                       association.exit_date
                     elsif class_name == 'casenote'
                       association.meeting_date
                     elsif class_name == 'call'
                       association.date_of_call
                     end
        distance_between_dates = (date_field.to_date - created_date.to_date).to_i
        created_date + distance_between_dates.day
      else
        association.created_at
      end
    end.sort_by { |k, v| k }.reverse.to_h
  end

  def referral_source_category(id)
    if I18n.locale == :km
      ReferralSource.find_by(id: id).try(:name)
    else
      ReferralSource.find_by(id: id).try(:name_en)
    end
  end

  def translate_exit_reasons(reasons)
    reason_translations = I18n.backend.send(:translations)[:en][:client][:exit_ngos][:edit_form][:exit_reason_options]
    current_translations = I18n.t('client.exit_ngos.edit_form.exit_reason_options')
    reasons.map do |reason|
      current_translations[reason_translations.key(reason)]
    end.join(', ')
  end

  def custom_id_translation(type)
    if I18n.locale != :km || Setting.first.country_name != 'lesotho'
      if type == 'custom_id1'
        Setting.first.custom_id1_latin.present? ? Setting.first.custom_id1_latin : I18n.t("#{I18n.locale.to_s}.clients.other_detail.custom_id_number1")
      else
        Setting.first.custom_id2_latin.present? ? Setting.first.custom_id2_latin : I18n.t('other_detail.custom_id_number2')
      end
    else
      if type == 'custom_id1'
        Setting.first.custom_id1_local.present? ? Setting.first.custom_id1_local : I18n.t('other_detail.custom_id_number1')
      else
        Setting.first.custom_id2_local.present? ? Setting.first.custom_id2_local : I18n.t('other_detail.custom_id_number2')
      end
    end
  end

  def client_donors
    @client.donors.distinct
  end

  def get_address_json
    Client::BRC_ADDRESS.zip(Client::BRC_ADDRESS).to_h.to_json
  end

  def get_quantitative_types
    if current_organization.short_name != 'brc'
      QuantitativeType.all
    else
      QuantitativeType.unscoped.where('quantitative_types.visible_on LIKE ?', '%client%').order("substring(quantitative_types.name, '^[0-9]+')::int, substring(quantitative_types.name, '[^0-9]*$')")
    end
  end

  def get_address(address_name)
    @client.public_send("#{address_name}") ? [@client.public_send("#{address_name}").slice('id', 'name')] : []
  end

  def in_used_custom_field?(custom_field)
    @readable_forms.map(&:custom_field_id).include?(custom_field.id)
  end

  def saved_search_column_visibility(field_key)
    client_default_columns ||= Setting.first.client_default_columns
    default_setting(field_key, client_default_columns) || params[field_key.to_sym].present? || (@visible_fields && @visible_fields[field_key]).present?
  end

  def legal_doc_fields
    FieldSetting.cache_legal_doc_fields
  end

  def if_date_of_birth_blank(client)
    return '#screening-tool-warning' if client.date_of_birth.blank?
    screening_assessment = @client.screening_assessments.first
    if screening_assessment && screening_assessment.screening_type == 'one_off'
      client_screening_assessment_path(client, screening_assessment)
    else
      new_client_screening_assessment_path(client, screening_type: 'one_off')
    end
  end

  def has_of_warning_model_if_dob_blank(client)
    return { "data-target": '#screening-tool-warning', "data-toggle": 'modal' } if client.date_of_birth.blank?
    {}
  end
end
