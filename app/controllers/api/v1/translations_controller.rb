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
            "users" => json[0]["en"]["users"],
            "asssessments" => json[0]["en"]["assessments"],
            "tasks" => json[0]["en"]["tasks"],
            "case_notes" => json[0]["en"]["case_notes"]
          },
          "km" => {
            "clients" => json[1]["km"]["clients"],
            "families" => json[1]["km"]["families"],
            "users" => json[1]["km"]["users"],
            "asssessments" => json[1]["km"]["assessments"],
            "tasks" => json[1]["km"]["tasks"],
            "case_notes" => json[1]["km"]["case_notes"]
          },

          "my" => {
            "clients" => json[2]["my"]["clients"],
            "families" => json[2]["my"]["families"],
            "users" => json[2]["my"]["users"],
            "asssessments" => json[2]["my"]["assessments"],
            "tasks" => json[2]["my"]["tasks"],
            "case_notes" => json[2]["my"]["case_notes"]
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
