module Api
  class CommunesController < AdminController
    def index
      data = District.find(params[:district_id]).communes
      render json: {
        data: ActiveModel::ArraySerializer.new(data, each_serializer: CommuneSerializer)
      }
    end
  end
end
