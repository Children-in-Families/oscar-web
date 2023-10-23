module ClientsConcern
  def referee_params
    return if params[:referee].nil?

    params.require(:referee).permit(
      :name, :phone, :outside, :address_type, :commune_id, :current_address, :district_id, :email, :gender, :house_number, :outside_address, :province_id, :street_number, :village_id, :anonymous,
      :state_id, :township_id, :subdistrict_id, :street_line1, :street_line2, :plot, :road, :postal_code, :suburb, :description_house_landmark, :directions, :locality
    )
  end

  def carer_params
    return if params[:carer].nil?

    params.require(:carer).permit(
      :name, :phone, :outside, :address_type, :current_address, :email, :gender, :house_number, :street_number, :outside_address, :commune_id, :district_id, :province_id, :village_id, :client_relationship, :same_as_client,
      :state_id, :township_id, :subdistrict_id, :street_line1, :street_line2, :plot, :road, :postal_code, :suburb, :description_house_landmark, :directions, :locality
    )
  end

  def risk_assessment_params
    return if params[:risk_assessment].nil?

    params.require(:risk_assessment).permit(
      :assessment_date, :other_protection_concern_specification, :client_perspective, :has_known_chronic_disease,
      :has_disability, :has_hiv_or_aid, :known_chronic_disease_specification, :disability_specification, :hiv_or_aid_specification,
      :relevant_referral_information, :level_of_risk, :history_of_disability_id, :history_of_harm_id, :history_of_high_risk_behaviour_id,
      :history_of_family_separation_id, protection_concern: [],
                                        tasks_attributes: [:id, :name, :expected_date, :client_id, :_destroy]
    )
  end
end
