module Api
  module V2
    class SettingsController < Api::V1::BaseApiController
      def index
        render json: Setting.first
      end
    end
  end
end
