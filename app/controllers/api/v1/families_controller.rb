module Api
  module V1
    class FamiliesController < Api::V1::BaseApiController

      def index
        render json: current_user.families
      end

      def listing
        families = Family.accessible_by(current_ability)
        render json: families, each_serializer: FamilyListingSerializer
      end

      def show
        family = find_family
        render json: family
      end

      def create
        family = Family.new(family_params)
        if family.save
          render json: family
        else
          render json: family.errors, status: :unprocessable_entity
        end
      end

      def update
        # @family.case_management_record = !current_setting.hide_family_case_management_tool?
        family = Family.find(params[:id])
        if family.update_attributes(family_params)
          render json: family
        else
          render json: family.errors, status: :unprocessable_entity
        end
      end

      private

      def find_family
        Family.find(params[:id])
      end

      def family_params
        permitted_params = params.require(:family).permit(
          :name, :code,
          :dependable_income, :family_type, :status, :contract_date,
          :address, :province_id, :district_id, :house, :street,
          :commune_id, :village_id, :slug,
          :followed_up_by_id, :follow_up_date, :name_en, :phone_number, :id_poor, :referral_source_id,
          :referee_phone_number, :relevant_information,
          :received_by_id, :initial_referral_date, :referral_source_category_id,
          donor_ids: [], community_ids: [],
          case_worker_ids: [],
          custom_field_ids: [],
          quantitative_case_ids: [],
          documents: [],
          community_member_attributes: [:id, :community_id, :_destroy],
          family_quantitative_free_text_cases_attributes: [
            :id, :content, :quantitative_type_id
          ],
          family_members_attributes: [
            :monthly_income, :client_id,
            :id, :gender, :note, :adult_name, :date_of_birth,
            :occupation, :relation, :guardian, :_destroy
          ]
        )

        permitted_params[:community_member_attributes][:_destroy] = 1 if permitted_params[:community_member_attributes].present? && permitted_params.dig(:community_member_attributes, :community_id).blank?

        permitted_params
      end
    end
  end
end
