module Api
  module V1
    class ClientsController < Api::V1::BaseApiController
      include ClientsConcern
      before_action :find_client, except: [:index, :listing, :create]

      def index
        clients = Client.accessible_by(current_ability)
        render json: clients
      end

      def listing
        clients = Client.accessible_by(current_ability)
        render json: clients, each_serializer: ClientListingSerializer
      end

      def show
        render json: @client
      end

      def create
        client = Client.new(client_params)
        if client.save
          render json: client
        else
          render json: client.errors, status: :unprocessable_entity
        end
      end

      def update
        client = Client.find(params[:client][:id] || params[:id])
        if client
          referee = Referee.find_or_create_by(id: params.dig(:referee, :id))
          referee.update_attributes(referee_params)
          client.referee_id = referee.id
          carer = Carer.find_or_create_by(id: client.carer_id || params.dig(:carer, :id))
          carer.update_attributes(carer_params)
          client.carer_id = carer.id
          client.current_family_id ? client_params : client_params.except(:family_ids)
        end

        if client.update_attributes(client_params.except(:referee_id, :carer_id))
          qtt_free_text_cases = params[:client_quantitative_free_text_cases]

          if qtt_free_text_cases.present?
            qtt_free_text_cases.select(&:present?).each do |client_qt_free_text_attr|
              client_qt_free_text = client.client_quantitative_free_text_cases.find_or_initialize_by(quantitative_type_id: client_qt_free_text_attr[:quantitative_type_id])
              client_qt_free_text.content = client_qt_free_text_attr[:content]
              client_qt_free_text.save
            end
          end

          if risk_assessment_params
            risk_assessment = RiskAssessmentReducer.new(client, risk_assessment_params, 'update')
            risk_assessment.store
          end
          render json: client
        else
          render json: client.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @client.transaction do
          @client.enter_ngos.each(&:destroy_fully!)
          @client.exit_ngos.each(&:destroy_fully!)
          @client.client_enrollments.each(&:destroy_fully!)
          @client.cases.delete_all
          @client.case_worker_clients.with_deleted.each(&:destroy_fully!)
        end
        @client.reload.destroy
        head 204
      end

      private

      def find_client
        @client = Client.accessible_by(current_ability).find(params[:id])
      end

      def client_params
        params.require(:client)
              .permit(
                :code, :name_of_referee, :main_school_contact, :rated_for_id_poor, :what3words, :status,
                :kid_id, :assessment_id, :given_name, :family_name, :local_given_name, :local_family_name, :gender, :date_of_birth,
                :birth_province_id, :initial_referral_date, :referral_source_id, :telephone_number,
                :referral_phone, :received_by_id, :followed_up_by_id,
                :follow_up_date, :school_grade, :school_name, :current_address, :external_id, :external_id_display,
                :house_number, :street_number, :suburb, :description_house_landmark, :directions, :street_line1, :street_line2, :plot, :road, :postal_code, :district_id, :subdistrict_id, :village_id, :commune_id,
                :has_been_in_orphanage, :has_been_in_government_care,
                :relevant_referral_information, :province_id, :profile,
                :state_id, :township_id, :rejected_note, :live_with, :rated_for_id_poor,
                :gov_city, :gov_commune, :gov_district, :gov_date, :gov_village_code, :gov_client_code,
                :gov_interview_village, :gov_interview_commune, :gov_interview_district, :gov_interview_city,
                :gov_caseworker_name, :gov_caseworker_phone, :gov_carer_name, :gov_carer_relationship, :gov_carer_home,
                :gov_carer_street, :gov_carer_village, :gov_carer_commune, :gov_carer_district, :gov_carer_city, :gov_carer_phone,
                :gov_information_source, :gov_referral_reason, :gov_guardian_comment, :gov_caseworker_comment, :referral_source_category_id,
                :global_id, :referee_relationship,
                interviewee_ids: [],
                client_type_ids: [],
                donor_ids: [],
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
  end
end
