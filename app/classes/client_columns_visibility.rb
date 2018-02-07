class ClientColumnsVisibility
  def initialize(grid, params)
    @grid   = grid
    @params = params
  end

  def columns_collection
    {
      live_with_: :live_with,
      id_poor_: :id_poor,
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
      case_type_: :cases,
      birth_province_id_: :birth_province,
      initial_referral_date_: :initial_referral_date,
      referral_phone_: :referral_phone,
      received_by_id_: :received_by,
      referral_source_id_: :referral_source,
      followed_up_by_id_: :followed_up_by,
      follow_up_date_: :follow_up_date,
      agencies_name_: :agency,
      province_id_: :province,
      current_address_: :current_address,
      house_number_: :house_number,
      street_number_: :street_number,
      village_: :village,
      commune_: :commune,
      district_: :district,
      school_name_: :school_name,
      school_grade_: :school_grade,
      has_been_in_orphanage_: :has_been_in_orphanage,
      has_been_in_government_care_: :has_been_in_government_care,
      relevant_referral_information_: :relevant_referral_information,
      user_ids_: :user,
      state_: :state,
      accepted_date_: :accepted_date,
      exit_date_: :exit_date,
      history_of_disability_and_or_illness_: :history_of_disability_and_or_illness,
      history_of_harm_: :history_of_harm,
      history_of_high_risk_behaviours_: :history_of_high_risk_behaviours,
      reason_for_family_separation_: :reason_for_family_separation,
      rejected_note_: :rejected_note,
      case_start_date_: :case_start_date,
      carer_names_: :carer_names,
      carer_address_: :carer_address,
      carer_phone_number_: :carer_phone_number,
      support_amount_: :support_amount,
      support_note_: :support_note,
      form_title_: :form_title,
      family_preservation_: :family_preservation,
      family_: :family,
      partner_: :partner,
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
      donor_: :donor,
      manage_: :manage,
      changelog_: :changelog,
      telephone_number_: :telephone_number
    }
  end

  def visible_columns
    @grid.column_names = []
    add_custom_builder_columns.each do |key, value|
      @grid.column_names << value if @params[key]
    end
  end

  private

  def domain_score_columns
    columns = columns_collection
    # if @params[:controller] != 'clients'
    Domain.order_by_identity.each do |domain|
      identity = domain.identity
      field = domain.convert_identity
      columns = columns.merge!("#{field}_": field.to_sym)
    end
    # end
    columns
  end

  def add_custom_builder_columns
    columns = domain_score_columns
    if @params[:column_form_builder].present?
      @params[:column_form_builder].each do |column|
        field   = column['id']
        columns = columns.merge!("#{field}_": field.to_sym)
      end
    end
    columns
  end
end
