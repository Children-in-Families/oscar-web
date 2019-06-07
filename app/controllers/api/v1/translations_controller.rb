module Api
  module V1
    class TranslationsController < Api::V1::BaseApiController
      require 'yaml'
      require 'json'

      def translation
        if ['en', 'km', 'my'].include?(params[:lang])
          yml = File.open(Rails.root.join("config/locales/#{params[:lang]}.yml"), 'r').read
          json = JSON.parse(JSON.dump(YAML::load(yml)))
          translates = {
            "clients" => json["#{params[:lang]}"]["clients"],
            "families" => json["#{params[:lang]}"]["families"],
            "users" => json["#{params[:lang]}"]["users"]
          }
          render json: translates
        else
          yml = File.open(Rails.root.join("config/locales/en.yml"), 'r').read
          json = JSON.parse(JSON.dump(YAML::load(yml)))
          translates = {
            "clients" => json["en"]["clients"],
            "families" => json["en"]["families"],
            "users" => json["en"]["users"]
          }
          render json: translates
        end
      end
    end
  end
end
