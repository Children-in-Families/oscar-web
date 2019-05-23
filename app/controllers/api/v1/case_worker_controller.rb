module Api
  module V1
    class CaseWorkerController < Api::V1::BaseApiController
      include Mongoid::Document
      def get_data
        case_worker_id = params[:id]
        binding.pry
      end
    end
  end
end