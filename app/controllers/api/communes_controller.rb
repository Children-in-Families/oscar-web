module Api
  class CommunesController < Api::ApplicationController
    def index
      data = District.find(params[:district_id]).communes
      render json: {
        data: ActiveModel::Serializer::CollectionSerializer.new(data, each_serializer: CommuneSerializer)
      }
    end
  end
end
