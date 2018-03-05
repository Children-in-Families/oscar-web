class ClientStepsController < ApplicationController
  include Wicked::Wizard

  steps :living_detail, :other_detail, :specific_point

  def show
    @provinces = Province.all
    @districts = District.all
    @province  = Province.order(:name)
    @donors    = Donor.all
    @agencies  = Agency.order(:name)
    @client    = Client.accessible_by(current_ability).friendly.find(session[:client_id])
    render_wizard
  end

  def update
    @client = Client.accessible_by(current_ability).friendly.find(session[:client_id])
    @client.update_attributes(client_params)
    render_wizard @client
  end

  private

  def redirect_to_finish_wizard
    redirect_to clients_path(@client), notice: "Update successfully."
  end

  def client_params
    params.require(:client)
          .permit(
            :primary_carer_name, :primary_carer_phone_number,
            :name_of_referee, :referee_phone_number,
            :main_school_contact, :rated_for_id_poor,
            :custom_id_number1, :custom_id_number2,
            :exit_note, :exit_date, :status,
            :kid_id, :assessment_id, :given_name, :family_name, :local_given_name, :local_family_name, :gender, :date_of_birth,
            :birth_province_id, :initial_referral_date, :referral_source_id, :telephone_number,
            :referral_phone, :received_by_id, :followed_up_by_id,
            :follow_up_date, :school_grade, :school_name, :current_address,
            :house_number, :street_number, :village, :commune, :district_id,
            :has_been_in_orphanage, :has_been_in_government_care,
            :relevant_referral_information, :province_id, :donor_id,
            :state, :rejected_note, :able, :live_with, :id_poor, :accepted_date,
            :gov_city, :gov_commune, :gov_district, :gov_date, :gov_village_code, :gov_client_code,
            :gov_interview_village, :gov_interview_commune, :gov_interview_district, :gov_interview_city,
            :gov_caseworker_name, :gov_caseworker_phone, :gov_carer_name, :gov_carer_relationship, :gov_carer_home,
            :gov_carer_street, :gov_carer_village, :gov_carer_commune, :gov_carer_district, :gov_carer_city, :gov_carer_phone,
            :gov_information_source, :gov_referral_reason, :gov_guardian_comment, :gov_caseworker_comment,
            interviewee_ids: [],
            client_type_ids: [],
            user_ids: [],
            agency_ids: [],
            quantitative_case_ids: [],
            custom_field_ids: [],
            tasks_attributes: [:name, :domain_id, :completion_date],
            client_needs_attributes: [:id, :rank, :need_id],
            client_problems_attributes: [:id, :rank, :problem_id]
          )
  end

end
