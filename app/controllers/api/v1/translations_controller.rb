module Api
  module V1
    class TranslationsController < Api::V1::BaseApiController
      require 'yaml'
      require 'json'

      def english
        en_yml = File.open(Rails.root.join('config/locales/en.yml'), 'r').read
        render json: JSON.dump(YAML::load(en_yml))
      end

      def khmer
        km_yml = File.open(Rails.root.join('config/locales/km.yml'), 'r').read
        render json: JSON.dump(YAML::load(km_yml))
      end

      def myanma
        my_yml = File.open(Rails.root.join('config/locales/my.yml'), 'r').read
        render json: JSON.dump(YAML::load(my_yml))
      end
    end
  end
end
