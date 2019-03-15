module Api
  module V1
    class BirthProvincesController < Api::V1::BaseApiController
      def index
        birth_province_ids = Client.pluck(:birth_province_id)
        birth_provinces = Province.where(id: birth_province_ids)
        
        render json: order_by_countries(birth_provinces)
      end

      def order_by_countries(provinces)
        {
          'Cambodia': provinces.country_is('cambodia'),
          'Thailand': provinces.country_is('thailand'),
          'Myanmar': provinces.country_is('myanmar'),
          'Lesotho': provinces.country_is('lesotho'),
          'Uganda': provinces.country_is('uganda'),
        }
      end
    end
  end
end
