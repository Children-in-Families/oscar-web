module Api
  module V1
    class FamiliesController < Api::V1::BaseApiController

      def index
        render json: Family.all
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
        family = Family.find(params[:id])
        if family.update_attributes(family_params)
          render json: family
        else
          render json: family.errors, status: :unprocessable_entity
        end
      end

      private

      def family_params
        params.require(:family).permit(
                                :name, :code, :case_history, :caregiver_information,
                                :significant_family_member_count, :household_income,
                                :dependable_income, :female_children_count,
                                :male_children_count, :female_adult_count,
                                :male_adult_count, :family_type, :status, :contract_date,
                                :address, :province_id, children: []
                                )
      end
    end
  end
end
