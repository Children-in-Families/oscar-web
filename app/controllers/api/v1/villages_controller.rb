module Api
  module V1
    class VillagesController < Api::V1::BaseApiController
      def index
        villages = Rails.cache.fetch([Apartment::Tenant.current, 'villages']) do
          ActiveModel::ArraySerializer.new(Village.order(:name_en), each_serializer: VillageSerializer)
        end
        render json: villages, root: 'villages'
      end
    end
  end
end
