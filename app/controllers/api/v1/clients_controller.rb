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
        client_saved = false
        client = Client.new(client_params)
        assign_global_id_from_referral(client, params)
        client.transaction do
          if params.dig(:referee, :id).present?
            referee = Referee.find(params.dig(:referee, :id))
            referee.update(referee_params)
          else
            if referee_params[:anonymous] == 'true'
              referee = Referee.new(referee_params)
            else
              referee = Referee.find_or_initialize_by(referee_params)
            end
            referee.save
          end

          carer = Carer.find_or_initialize_by(carer_params)
          carer.save

          client.referee_id = referee.id
          client.carer_id = carer.id
          client_saved = client.save
        end

        if client_saved
          qtt_free_text_cases = params[:client_quantitative_free_text_cases]

          if qtt_free_text_cases.present?
            qtt_free_text_cases.select(&:present?).each do |client_qt_free_text_attr|
              client_qt_free_text = client.client_quantitative_free_text_cases.find_or_initialize_by(quantitative_type_id: client_qt_free_text_attr[:quantitative_type_id])
              client_qt_free_text.content = client_qt_free_text_attr[:content]
              client_qt_free_text.save
            end
          end

          if risk_assessment_params
            risk_assessment = RiskAssessmentReducer.new(client, risk_assessment_params, 'create')
            risk_assessment.store
          end

          custom_data = CustomData.first
          client.create_client_custom_data(custom_data_params.merge(custom_data_id: custom_data.id)) if custom_data && params.key?(:custom_data)

          render json: { slug: client.slug, id: client.id }, status: :ok
        else
          render json: client.errors, status: :unprocessable_entity
        end
      end

      def update
        client = Client.find(params[:client][:id] || params[:id])
        if params[:client][:id]
          referee = Referee.find_or_create_by(id: client.referee_id)
          referee.update_attributes(referee_params)
          client.referee_id = referee.id
          carer = Carer.find_or_create_by(id: client.carer_id)
          carer.update_attributes(carer_params)
          client.carer_id = carer.id
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

          custom_data = CustomData.first
          if custom_data && params.key?(:custom_data)
            if client.client_custom_data&.persisted?
              client.client_custom_data.update_attributes(custom_data_params)
            else
              client.create_client_custom_data(custom_data_params.merge(custom_data_id: custom_data.id))
            end
          end

          if params[:client][:assessment_id]
            Assessment.find(params[:client][:assessment_id])
          else
            render json: { slug: client.slug }, status: :ok
          end
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
        permited_params = params.require(:client)
          .permit(
            :code, :name_of_referee, :main_school_contact, :rated_for_id_poor, :what3words, :status,
            :kid_id, :assessment_id, :given_name, :family_name, :local_given_name, :local_family_name, :gender, :date_of_birth,
            :birth_province_id, :initial_referral_date, :referral_source_id, :telephone_number,
            :referral_phone, :received_by_id, :followed_up_by_id, :current_family_id,
            :follow_up_date, :school_grade, :school_name, :current_address, :external_id, :external_id_display,
            :house_number, :street_number, :suburb, :description_house_landmark, :directions, :street_line1, :street_line2, :plot, :road, :postal_code, :district_id, :subdistrict_id, :village_id, :commune_id,
            :has_been_in_orphanage, :has_been_in_government_care, :phone_owner,
            :relevant_referral_information, :province_id, :city_id, :profile, :client_phone,
            :state_id, :township_id, :rejected_note, :live_with, :rated_for_id_poor,
            :gov_city, :gov_commune, :gov_district, :gov_date, :gov_village_code, :gov_client_code,
            :gov_interview_village, :gov_interview_commune, :gov_interview_district, :gov_interview_city,
            :gov_caseworker_name, :gov_caseworker_phone, :gov_carer_name, :gov_carer_relationship, :gov_carer_home,
            :gov_carer_street, :gov_carer_village, :gov_carer_commune, :gov_carer_district, :gov_carer_city, :gov_carer_phone,
            :gov_information_source, :gov_referral_reason, :gov_guardian_comment, :gov_caseworker_comment, :referral_source_category_id,
            :global_id, :referee_relationship, :client_email, :address_type,
            interviewee_ids: [],
            client_type_ids: [],
            donor_ids: [],
            user_ids: [],
            agency_ids: [],
            quantitative_case_ids: [],
            custom_field_ids: [],
            tasks_attributes: [:name, :domain_id, :completion_date],
            client_needs_attributes: [:id, :rank, :need_id],
            family_member_attributes: [:id, :family_id, :_destroy],
            client_problems_attributes: [:id, :rank, :problem_id]
          )

        if params[:family_member]
          permited_params[:family_member_attributes] = params[:family_member].permit(%i[id family_id])
          permited_params[:family_member_attributes][:_destroy] = 1 if permited_params[:family_member_attributes].present? && permited_params.dig(:family_member_attributes, :family_id).blank?
        end

        permited_params
      end
    end
  end
end
