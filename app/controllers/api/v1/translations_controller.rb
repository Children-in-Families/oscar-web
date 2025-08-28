module Api
  module V1
    class TranslationsController < Api::V1::BaseApiController
      require 'yaml'
      require 'json'

      def translation
        if ['en', 'km', 'my', 'in', 'th', 'en'].include?(params[:lang])
          yml = File.open(Rails.root.join("config/locales/#{params[:lang]}.yml"), 'r').read
          render json: JSON.dump(YAML::load(yml))
        else
          yml = File.open(Rails.root.join('config/locales/en.yml'), 'r').read
          render json: JSON.dump(YAML::load(yml))
        end
      end
    end
  end
end
