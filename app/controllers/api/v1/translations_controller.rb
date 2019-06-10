module Api
  module V1
    class TranslationsController < Api::V1::BaseApiController
      require 'yaml'
      require 'json'

      def translation
        json = []
        ['en', 'km', 'my'].each do |lang|
          yml = File.open(Rails.root.join("config/locales/#{lang}.yml"), 'r').read
          json << JSON.parse(JSON.dump(YAML::load(yml)))
        end

        translations = {
          "en" => {
            "clients" => json[0]["en"]["clients"],
            "families" => json[0]["en"]["families"],
            "users" => json[0]["en"]["users"]
          },
          "km" => {
            "clients" => json[1]["km"]["clients"],
            "families" => json[1]["km"]["families"],
            "users" => json[1]["km"]["users"],
          },

          "my" => {
            "clients" => json[2]["my"]["clients"],
            "families" => json[2]["my"]["families"],
            "users" => json[2]["my"]["users"]
          }
        }

        render json: translations

        # if ['en', 'km', 'my'].include?(params[:lang])
        #   yml = File.open(Rails.root.join("config/locales/#{params[:lang]}.yml"), 'r').read
        #   json = JSON.parse(JSON.dump(YAML::load(yml)))
        #   translates = {
        #     "clients" => json["#{params[:lang]}"]["clients"],
        #     "families" => json["#{params[:lang]}"]["families"],
        #     "users" => json["#{params[:lang]}"]["users"]
        #   }
        #   render json: translates
        # else
        #   yml = File.open(Rails.root.join("config/locales/en.yml"), 'r').read
        #   json = JSON.parse(JSON.dump(YAML::load(yml)))
        #   translates = {
        #     "clients" => json["en"]["clients"],
        #     "families" => json["en"]["families"],
        #     "users" => json["en"]["users"]
        #   }
        #   render json: translates
        # end
      end
    end
  end
end
