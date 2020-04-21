module Api
  module V1
    class BirthProvincesController < Api::V1::BaseApiController

      def index
        current_org = Organization.current.short_name
        Organization.switch_to 'shared'
        countries = ['Cambodia', 'Thailand', 'Myanmar', 'Lesotho', 'Uganda']
        provinces = countries.map{ |country| { country: country, provinces: Province.country_is(country.downcase).reload } }
        Organization.switch_to current_org

        render json: provinces
      end
    end
  end
end
