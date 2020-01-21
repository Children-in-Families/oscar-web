module Api
  module V1
    class CallsController < Api::ApplicationController

      def index
        calls = Call.order(created_at: :desc)
        render json: calls
      end

      def create
        call = Call.new(call_params)
        client = Client.new(client_params)
        
        referee = Referee.find_or_initialize_by(id: params["referee"]["id"])
        # referee.save

        carer = Carer.new(carer_params)
        # carer.save
        client.received_by_id = call.receiving_staff_id # if Receiving Staff is Receiving Staff Member
        client.initial_referral_date = call.date_of_call
        # client.referee_id = referee.id
        # client.carer_id = carer.id

        if tagged_with_client?(call.call_type)
          # create all objects
          if client.valid?
            if referee.valid?
              if call.valid?
                referee.save
                carer.save
                client.referee_id = referee.id
                client.carer_id = carer.id
                client.save

                if params[:task].present?
                  task_attr = {
                    name: "Call #{referee.name} on #{referee.phone} to update about #{client.slug}",
                    domain_id: Domain.find_by(name: '3B').id,
                    completion_date: params[:task][:completion_date],
                    relation: params[:task][:relation]
                  }
                  client.tasks.create(task_attr)
                end

                if (call.call_type == "New Referral: Case Action Required")
                  # auto accept client
                  client.enter_ngos.create(accepted_date: Date.today)
                end

                call.referee_id = referee.id
                # this if for one or multiple clients
                call.client_ids = [client.id]
                call.save

                client_urls = call.clients.map{ |client| client_url(client) }
                render json: { call: call, client_urls: client_urls }
              else
                render json: call.errors, status: :unprocessable_entity
              end
            else
              render json: referee.errors, status: :unprocessable_entity
            end
          else
            render json: client.errors, status: :unprocessable_entity
          end
        elsif (call.call_type == "Providing Update")
          # create call & referee, and attach referee to existing client
          # does not create carer, does not creater client
        else
          # seeiking info, spam call & wrong number
          # create call and referee, does not create client & carer.
        end

        # if call.save
        #   render json: call
        # else
        #   render json: call.errors, status: :unprocessable_entity
        # end
      end

      def edit_referee
        @call = Call.find(params[:id])
        @referee = @call.referee
      end

      def update_referee
        call = Call.find(params[:call_id])
        referee = call.referee
        if referee.update_attributes(referee_params)
          render json: call
        else
          render json: referee.errors
        end

      end
      
      def update
        call = Call.find(params[:id])

        if call.update_attributes(call_params)
          render json: call
        else
          render json: call.errors
        end
      end
      

      def show
        if call
          render json: call
        else
          render json: call.errors
        end
      end

      private

      def call_params
        params.require(:call).permit(:phone_call_id, :receiving_staff_id,
                                :date_of_call, :start_datetime, :end_datetime, :call_type,
                                :phone_counselling_summary, :information_provided,
                                client_ids: []
                                )
      end

      def referee_params
        params.require(:referee).permit(
          :name, :phone, :outside, :address_type, :commune_id,
          :current_address, :district_id, :email, :gender, :house_number,
          :outside_address, :province_id, :street_number, :village_id, :anonymous,
          :answered_call, :called_before, :adult, :requested_update
        )
      end

      def carer_params
        params.require(:carer).permit(
          :name, :phone, :outside, :address_type, :current_address, :email, :gender,
          :house_number, :street_number, :outside_address, :commune_id, :district_id,
          :province_id,  :village_id, :client_relationship, :same_as_client
        )
      end

      def client_params
        params.require(:client).permit(
              :slug, :archived_slug, :code, :name_of_referee, :main_school_contact, :rated_for_id_poor, :what3words, :status, :country_origin,
              :kid_id, :assessment_id, :given_name, :family_name, :local_given_name, :local_family_name, :gender, :date_of_birth,
              :birth_province_id, :initial_referral_date, :referral_source_id, :telephone_number,
              :referral_phone, :received_by_id, :followed_up_by_id,
              :follow_up_date, :school_grade, :school_name, :current_address,
              :house_number, :street_number, :suburb, :description_house_landmark, :directions, :street_line1, :street_line2, :plot, :road, :postal_code, :district_id, :subdistrict_id,
              :has_been_in_orphanage, :has_been_in_government_care,
              :relevant_referral_information, :province_id,
              :state_id, :township_id, :rejected_note, :live_with, :profile, :remove_profile,
              :gov_city, :gov_commune, :gov_district, :gov_date, :gov_village_code, :gov_client_code,
              :gov_interview_village, :gov_interview_commune, :gov_interview_district, :gov_interview_city,
              :gov_caseworker_name, :gov_caseworker_phone, :gov_carer_name, :gov_carer_relationship, :gov_carer_home,
              :gov_carer_street, :gov_carer_village, :gov_carer_commune, :gov_carer_district, :gov_carer_city, :gov_carer_phone,
              :gov_information_source, :gov_referral_reason, :gov_guardian_comment, :gov_caseworker_comment, :commune_id, :village_id, :referral_source_category_id, :referee_id, :carer_id,
              :address_type, :phone_owner, :client_phone, :client_email, :referee_relationship, :outside, :outside_address,

              :nickname, :relation_to_referee, :concern_is_outside, :concern_outside_address,
              :concern_province_id, :concern_district_id, :concern_commune_id, :concern_village_id,
              :concern_street, :concern_house, :concern_address, :concern_address_type,
              :concern_phone, :concern_phone_owner, :concern_email, :concern_email_owner, :concern_location,

              interviewee_ids: [],
              client_type_ids: [],
              user_ids: [],
              agency_ids: [],
              donor_ids: [],
              quantitative_case_ids: [],
              custom_field_ids: [],
              tasks_attributes: [:name, :domain_id, :completion_date],
              client_needs_attributes: [:id, :rank, :need_id],
              client_problems_attributes: [:id, :rank, :problem_id],
              family_ids: [],
              call_ids: []
            )
      end

      def call
        @call ||= Call.find(params[:id])
      end

      def tagged_with_client?(call_type)
        ["New Referral: Case Action Required", "New Referral: Case Action NOT Required", "Phone Counseling"].include?(call_type)
      end
    end
  end
end
