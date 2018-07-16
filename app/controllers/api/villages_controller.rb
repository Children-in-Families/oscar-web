module Api
  class VillagesController < AdminController
    def index
      # data = Commune.find(params[:commune_id]).villages
      # render json: { data: data }
      # binding.pry
      data = Commune.find(params[:commune_id]).villages
      render json: {
        data: ActiveModel::ArraySerializer.new(data, each_serializer: VillageSerializer)
      }
    end
  end
end

# module Api
#   class CommunesController < AdminController
#     def index
#       data = District.find(params[:district_id]).communes
#       render json: {
#         data: ActiveModel::ArraySerializer.new(data, each_serializer: CommuneSerializer)
#       }
#     end
#   end
# end
