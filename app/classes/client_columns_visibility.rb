class ClientColumnsVisibility
  def initialize(grid, params)
    @grid   = grid
    @params = params
  end

  def columns_collection
    {
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
      school_name_: :school_name,
      grade_: :grade,
      able_state_: :able_state,
      has_been_in_orphanage_: :has_been_in_orphanage,
      has_been_in_government_care_: :has_been_in_government_care,
      relevant_referral_information_: :relevant_referral_information,
      user_id_: :user,
      state_: :state,
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
      manage_: :manage,
      code_: :code,
      age_: :age,
      slug_: :slug,
      kid_id_: :kid_id,
      family_id_: :family_id,
      any_assessments_: :any_assessments,
      donor_: :donor
    }
  end

  def visible_columns
    @grid.column_names = []
    columns_collection.each do |key, value|
      @grid.column_names << value if @params[key]
    end
  end
end
