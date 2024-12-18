class ClientColumnsVisibility
  include AdvancedSearchHelper
  include ClientsHelper
  include ActionView::Helpers::TranslationHelper

  def initialize(grid, params)
    @grid = grid
    @params = params
    address_translation
  end

  def columns_collection
    {
      national_id_number_: :national_id_number,
      passport_number_: :passport_number,
      neighbor_name_: :neighbor_name,
      neighbor_phone_: :neighbor_phone,
      dosavy_name_: :dosavy_name,
      dosavy_phone_: :dosavy_phone,
      chief_commune_name_: :chief_commune_name,
      chief_commune_phone_: :chief_commune_phone,
      chief_village_name_: :chief_village_name,
      chief_village_phone_: :chief_village_phone,
      ccwc_name_: :ccwc_name,
      ccwc_phone_: :ccwc_phone,
      legal_team_name_: :legal_team_name,
      legal_representative_name_: :legal_representative_name,
      legal_team_phone_: :legal_team_phone,
      other_agency_name_: :other_agency_name,
      other_representative_name_: :other_representative_name,
      other_agency_phone_: :other_agency_phone,
      exit_reasons_: :exit_reasons,
      exit_circumstance_: :exit_circumstance,
      other_info_of_exit_: :other_info_of_exit,
      exit_note_: :exit_note,
      presented_id_: :presented_id,
      id_number_: :id_number,
      legacy_brcs_id_: :legacy_brcs_id,
      whatsapp_: :whatsapp,
      other_phone_number_: :other_phone_number,
      brsc_branch_: :brsc_branch,
      current_island_: :current_island,
      preferred_language_: :preferred_language,
      current_street_: :current_street,
      current_po_box_: :current_po_box,
      current_city_: :current_city,
      current_settlement_: :current_settlement,
      current_resident_own_or_rent_: :current_resident_own_or_rent,
      current_household_type_: :current_household_type,
      island2_: :island2,
      street2_: :street2,
      po_box2_: :po_box2,
      city2_: :city2,
      settlement2_: :settlement2,
      resident_own_or_rent2_: :resident_own_or_rent2,
      household_type2_: :household_type2,
      what3words_: :what3words,
      national_id_: :national_id,
      birth_cert_: :birth_cert,
      family_book_: :family_book,
      passport_: :passport,
      marital_status_: :marital_status,
      nationality_: :nationality,
      ethnicity_: :ethnicity,
      location_of_concern_: :location_of_concern,
      type_of_trafficking_: :type_of_trafficking,
      education_background_: :education_background,
      department_: :department,
      travel_doc_: :travel_doc,
      referral_doc_: :referral_doc,
      local_consent_: :local_consent,
      police_interview_: :police_interview,
      other_legal_doc_: :other_legal_doc,
      # name_of_referee_: :name_of_referee,
      rated_for_id_poor_: :rated_for_id_poor,
      main_school_contact_: :main_school_contact,
      program_streams_: :program_streams,
      program_enrollment_date_: :program_enrollment_date,
      program_exit_date_: :program_exit_date,
      given_name_: :given_name,
      family_name_: :family_name,
      local_given_name_: :local_given_name,
      local_family_name_: :local_family_name,
      gender_: :gender,
      date_of_birth_: :date_of_birth,
      status_: :status,
      **Client::HOTLINE_FIELDS.map { |field| ["#{field}_".to_sym, field.to_sym] }.to_h,
      birth_province_id_: :birth_province_id,
      initial_referral_date_: :initial_referral_date,
      # referral_phone_: :referral_phone,
      received_by_id_: :received_by,
      referral_source_id_: :referral_source_id,
      followed_up_by_id_: :followed_up_by,
      follow_up_date_: :follow_up_date,
      agencies_name_: :agency,
      donor_name_: :donor,
      province_id_: :province_id,
      current_address_: :current_address,
      house_number_: :house_number,
      street_number_: :street_number,
      district_: :district,
      subdistrict_: :subdistrict,
      state_: :state,
      township_: :township,
      suburb_: :suburb,
      description_house_landmark_: :description_house_landmark,
      directions_: :directions,
      street_line1_: :street_line1,
      street_line2_: :street_line2,
      postal_code_: :postal_code,
      plot_: :plot,
      road_: :road,
      school_name_: :school_name,
      school_grade_: :school_grade,
      has_been_in_orphanage_: :has_been_in_orphanage,
      has_been_in_government_care_: :has_been_in_government_care,
      relevant_referral_information_: :relevant_referral_information,
      user_id_: :user,
      accepted_date_: :accepted_date,
      exit_date_: :exit_date,
      history_of_disability_and_or_illness_: :history_of_disability_and_or_illness,
      history_of_harm_: :history_of_harm,
      history_of_high_risk_behaviours_: :history_of_high_risk_behaviours,
      reason_for_family_separation_: :reason_for_family_separation,
      rejected_note_: :rejected_note,
      family_: :family,
      family_type_: :family_type,
      code_: :code,
      age_: :age,
      slug_: :slug,
      kid_id_: :kid_id,
      family_id_: :family_id,
      any_assessments_: :any_assessments,
      case_note_date_: :case_note_date,
      case_note_type_: :case_note_type,
      assessment_created_at_: :assessment_created_at,
      date_of_assessments_: :date_of_assessments,
      assessment_completed_date_: :assessment_completed_date,
      custom_completed_date_: :custom_completed_date,
      completed_date_: :completed_date,
      all_csi_assessments_: :all_csi_assessments,
      custom_assessment_created_at_: :custom_assessment_created_at,
      date_of_custom_assessments_: :date_of_custom_assessments,
      all_custom_csi_assessments_: :all_custom_csi_assessments,
      all_result_framework_assessments_: :all_result_framework_assessments,
      manage_: :manage,
      changelog_: :changelog,
      commune_: :commune,
      village_: :village,
      created_at_: :created_at,
      created_by_: :created_by,
      referred_to_: :referred_to,
      referred_from_: :referred_from,
      referred_in_: :referred_in,
      referred_out_: :referred_out,
      date_of_referral_: :date_of_referral,
      # time_in_care_: :time_in_care,
      time_in_ngo_: :time_in_ngo,
      time_in_cps_: :time_in_cps,
      referral_source_category_id_: :referral_source_category_id,
      type_of_service_: :type_of_service,
      referee_name_: :referee_name,
      referee_phone_: :referee_phone,
      referee_email_: :referee_email,
      **Call::FIELDS.map { |field| ["#{field}_".to_sym, field.to_sym] }.to_h,
      **cn_custom_field_columns.map { |field| ["#{field}_".to_sym, field.to_sym] }.to_h,
      call_count: :call_count,
      carer_name_: :carer_name,
      carer_phone_: :carer_phone,
      carer_email_: :carer_email,
      carer_relationship_to_client_: :carer_relationship_to_client,
      phone_owner_: :phone_owner,
      referee_relationship_to_client_: :referee_relationship_to_client,
      client_phone_: :client_phone,
      address_type_: :address_type,
      client_email_: :client_email,
      indirect_beneficiaries_: :indirect_beneficiaries,
      care_plan_date_: :care_plan_date,
      care_plan_completed_date_: :care_plan_completed_date,
      care_plan_count_: :care_plan_count,
      arrival_at_: :arrival_at,
      flight_nb_: :flight_nb,
      ratanak_achievement_program_staff_client_ids_: :ratanak_achievement_program_staff_client_ids,
      mosavy_official_: :mosavy_official,
      level_of_risk_: :level_of_risk,
      date_of_risk_assessment_: :date_of_risk_assessment,
      has_hiv_or_aid_: :has_hiv_or_aid,
      has_known_chronic_disease_: :has_known_chronic_disease,
      has_disability_: :has_disability,
      **@params.select { |param| param[/\d_/] }.symbolize_keys
    }.merge(label_translations.keys.map { |field| ["#{field}_".to_sym, field.to_sym] }.to_h)
  end

  def visible_columns
    return [] if @grid.nil?
    @grid.column_names = []
    client_default_columns = Setting.first.client_default_columns

    params = @params.keys.select { |k| k.match(/\_$/) }
    if params.present? && client_default_columns.present?
      defualt_columns = params - client_default_columns
    else
      if params.present?
        defualt_columns = params
      else
        defualt_columns = client_default_columns
      end
    end

    add_custom_builder_columns.each do |key, value|
      @grid.column_names << value if client_default(key, defualt_columns) || @params[key]
    end
  end

  private

  def domain_score_columns
    columns = columns_collection
    Domain.cache_order_by_identity.each do |domain|
      field = domain.custom_domain ? "custom_#{domain.convert_identity}" : domain.convert_identity
      columns.merge!("#{field}_": field.to_sym)
    end
    columns
  end

  def quantitative_type_columns
    columns = domain_score_columns
    QuantitativeType.cach_by_visible_on('client').each do |quantitative_type|
      field = quantitative_type.name
      columns.merge!("#{field}_": field.to_sym)
    end
    columns
  end

  def add_custom_builder_columns
    columns = quantitative_type_columns
    if @params[:column_form_builder].present?
      @params[:column_form_builder].each do |column|
        field = column['id']
        columns.merge!("#{field}_": field.to_sym)
      end
    end

    columns
  end

  def cn_custom_field_columns
    custom_field = CaseNotes::CustomField.first
    return [] if custom_field.nil?

    custom_field.data_fields.map do |field|
      "case_note_custom_field_#{field['label'].parameterize.underscore}"
    end
  end

  def client_default(column, setting_client_default_columns)
    return false if setting_client_default_columns.nil?

    setting_client_default_columns.include?(column.to_s) if @params.dig(:client_grid, :descending).present? || (@params[:client_advanced_search].present? && @params.dig(:client_grid, :descending).present?) || @params[:client_grid].nil? || @params[:client_advanced_search].nil?
  end
end
