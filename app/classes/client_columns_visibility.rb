class ClientColumnsVisibility
  def initialize(grid, params)
    @grid   = grid
    @params = params
  end

  def columns_collection
    {
      live_with_: :live_with,
      exit_reasons_: :exit_reasons,
      exit_circumstance_: :exit_circumstance,
      other_info_of_exit_: :other_info_of_exit,
      exit_note_: :exit_note,
      what3words_: :what3words,
      name_of_referee_: :name_of_referee,
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
      birth_province_id_: :birth_province,
      initial_referral_date_: :initial_referral_date,
      referral_phone_: :referral_phone,
      received_by_id_: :received_by,
      referral_source_id_: :referral_source,
      followed_up_by_id_: :followed_up_by,
      follow_up_date_: :follow_up_date,
      agencies_name_: :agency,
      donors_name_: :donor,
      province_id_: :province,
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
      user_ids_: :user,
      accepted_date_: :accepted_date,
      exit_date_: :exit_date,
      history_of_disability_and_or_illness_: :history_of_disability_and_or_illness,
      history_of_harm_: :history_of_harm,
      history_of_high_risk_behaviours_: :history_of_high_risk_behaviours,
      reason_for_family_separation_: :reason_for_family_separation,
      rejected_note_: :rejected_note,
      family_: :family,
      code_: :code,
      age_: :age,
      slug_: :slug,
      kid_id_: :kid_id,
      family_id_: :family_id,
      any_assessments_: :any_assessments,
      case_note_date_: :case_note_date,
      case_note_type_: :case_note_type,
      date_of_assessments_: :date_of_assessments,
      all_csi_assessments_: :all_csi_assessments,
      manage_: :manage,
      changelog_: :changelog,
      telephone_number_: :telephone_number,
      commune_: :commune,
      village_: :village,
      created_at_: :created_at,
      created_by_: :created_by,
      referred_to_: :referred_to,
      referred_from_: :referred_from,
      time_in_care_: :time_in_care
    }
  end

  def visible_columns
    @grid.column_names = []
    client_default_columns = Setting.first.try(:client_default_columns)
    params = @params.keys.select{ |k| k.match(/\_$/) }
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
    Domain.order_by_identity.each do |domain|
      identity = domain.identity
      field = domain.convert_identity
      columns = columns.merge!("#{field}_": field.to_sym)
    end
    columns
  end

  def quantitative_type_columns
    columns = domain_score_columns
    QuantitativeType.joins(:quantitative_cases).uniq.each do |quantitative_type|
      field = quantitative_type.name
      columns = columns.merge!("#{field}_": field.to_sym)
    end
    columns
  end

  def add_custom_builder_columns
    columns = quantitative_type_columns
    if @params[:column_form_builder].present?
      @params[:column_form_builder].each do |column|
        field   = column['id']
        columns = columns.merge!("#{field}_": field.to_sym)
      end
    end
    columns
  end

  def client_default(column, setting_client_default_columns)
    return false if setting_client_default_columns.nil?
    setting_client_default_columns.include?(column.to_s) if @params.dig(:client_grid, :descending).present? || (@params[:client_advanced_search].present? && @params.dig(:client_grid, :descending).present?) || @params[:client_grid].nil? || @params[:client_advanced_search].nil?
  end
end
