module Api
  module V1
    class CaseWorkerController < Api::V1::BaseApiController
      def get_data
        Mongoid.raise_not_found_error = false
        case_worker_id = params[:id]
        case_worker    = CaseWorker.find_by(slug_id: case_worker_id)
        render json: case_worker
      end
    end
  end
end