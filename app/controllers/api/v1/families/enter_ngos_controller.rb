module Api
  module V1
    class Families::EnterNgosController < Api::V1::BaseApiController
      before_action :find_family

      def create
        enter_ngo = @family.enter_ngos.new(enter_ngo_params)
        if enter_ngo.save
          render json: @family.reload
        else
          render json: @family.errors, status: :unprocessable_entity
        end
      end

      def update
        enter_ngo = @family.enter_ngos.find(params[:id])
        authorize enter_ngo
        if enter_ngo.update_attributes(enter_ngo_params)
          render json: @family.reload
        else
          render json: @family.errors, status: :unprocessable_entity
        end
      end

      private

      def find_family
        @family = Family.accessible_by(current_ability).find(params[:family_id])
      end

      def enter_ngo_params
        params.require(:enter_ngo).permit(:accepted_date, user_ids: [])
      end
    end
  end
end
