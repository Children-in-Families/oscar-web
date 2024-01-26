module Api
  module V1
    class Clients::EnterNgosController < Api::V1::BaseApiController
      before_action :find_client_by_slug

      def create
        enter_ngo = @client.enter_ngos.new(enter_ngo_params)
        
        if !@client.accepted? && enter_ngo.save
          render json: @client
        else
          render json: @client.errors, status: :unprocessable_entity
        end
      end

      def update
        enter_ngo = @client.enter_ngos.find(params[:id])
        authorize enter_ngo
        
        if !@client.accepted? && enter_ngo.update_attributes(enter_ngo_params)
          render json: @client
        else
          render json: @client.errors, status: :unprocessable_entity
        end
      end

      private

      def find_client_by_slug
        @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
      end

      def enter_ngo_params
        params.require(:enter_ngo).permit(:accepted_date, user_ids: [])
      end
    end
  end
end
