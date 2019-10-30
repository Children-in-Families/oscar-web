module Api
  module V2
    class CaseWorkerClientOfflineController < Api::V1::BaseApiController
      def get_data
        Mongoid.raise_not_found_error = false
        clients = {}
        case_worker_client_ids = current_user.clients.pluck(:archived_slug)
        case_worker_client_ids.each do |id|
          client = CaseWorkerClientOffline.find_by(slug_id: id).try(:object)
          clients[id] = client.slice!(:archive_district,
                                      :archive_state,
                                      :completed,
                                      :old_village,
                                      :old_commune,
                                      :able,
                                      :able_state,
                                      :background,
                                      :directions,
                                      :plot,
                                      :gov_city,
                                      :gov_commune,
                                      :gov_district,
                                      :gov_date,
                                      :gov_village_code,
                                      :gov_client_code,
                                      :gov_interview_village,
                                      :gov_interview_commune,
                                      :gov_interview_district,
                                      :gov_interview_city,
                                      :gov_caseworker_name,
                                      :gov_caseworker_phone,
                                      :gov_carer_name,
                                      :gov_carer_relationship,
                                      :gov_carer_home,
                                      :gov_carer_street,
                                      :gov_carer_village,
                                      :gov_carer_commune,
                                      :gov_carer_district,
                                      :gov_carer_city,
                                      :gov_carer_phone,
                                      :gov_information_source,
                                      :gov_referral_reason,
                                      :gov_guardian_comment,
                                      :gov_caseworker_comment
                                      ) if client.present?
        end
        render json: clients
      end
    end
  end
end
