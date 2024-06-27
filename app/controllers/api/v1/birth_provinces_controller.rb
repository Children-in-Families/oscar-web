module Api
  module V1
    class BirthProvincesController < Api::V1::BaseApiController

      def index
        current_org = current_organization&.short_name || Apartment::Tenant.current
        Organization.switch_to 'shared'
        countries = Organization.pluck(:country).uniq.reject(&:blank?)
        provinces = countries.map{ |country| { country: country.titleize, provinces: Province.country_is(country).reload } }
        Organization.switch_to current_org

        render json: provinces
      end
    end
  end
end
