module Api
  class VillagesController < Api::ApplicationController
    def index
      data = Commune.find(params[:commune_id]).villages
      render json: {
        data: ActiveModel::ArraySerializer.new(data, each_serializer: VillageSerializer)
      }
    end
  end
end
