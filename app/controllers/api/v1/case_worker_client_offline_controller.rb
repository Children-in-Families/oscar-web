module Api
  module V1
    class CaseWorkerClientOfflineController < Api::V1::BaseApiController
      def get_data
        Mongoid.raise_not_found_error = false
        clients = {}
        case_worker_client_ids = current_user.clients.pluck(:archived_slug)

        case_worker_client_ids.each do |id|
          client = CaseWorkerClientOffline.find_by(slug_id: id).try(:object)
          clients[id] = client.slice!(:archive_district, :archive_state, :completed, :old_village, :old_commune, :able, :able_state, :background, :directions, :plot) if client.present?
        end
        render json: clients
      end
    end
  end
end
