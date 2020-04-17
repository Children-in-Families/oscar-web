module Api
  module V1
    class OrganizationsController < Api::V1::BaseApiController
      skip_before_action :authenticate_user!, only: :index

      def index
        render json: Organization.visible.order(:created_at)
      end

      def clients
        bulk_clients = []
        Organization.only_integrated.pluck(:short_name).each do |short_name|
          Organization.switch_to short_name
          clients = JSON.parse ActiveModel::ArraySerializer.new(Client.limit(10).to_a, each_serializer: OrganizationClientSerializer).to_json
          bulk_clients << clients
        end
        Organization.switch_to 'public'

        render json: bulk_clients.flatten.compact, root: :data
      end

      def create_many
        binding.pry
        ClientsTransaction.initial(params[:transaction_id], clients_params)
        clients_params[:organization].group_by{ |data| data[:organization_name] }.each do |short_name, data|
          Organization.switch_to short_name
          update_or_referred_client(data)
        end
        Organization.switch_to 'public'
        render json: { message: 'The data has been received successfully.' }, root: :data
      end

      private

        def clients_params
          params.permit(
            organization:
              [
                :global_id, :external_id, :external_id_display, :mosvy_number,
                :given_name, :family_name, :gender, :date_of_birth, :location_current_village_code,
                :address_current_village_code, :reason_for_referral, :reason_for_exiting,
                :organization_id, :organization_name, :external_case_worker_name,
                :external_case_worker_id, :external_case_worker_, :protection_status,
                services: [:id, :name]
              ]
            )
        end

        def update_or_referred_client(data)
          client = Client.find_by(global_id: data['global_id'])


          if client
            client.update_attributes(

            )
          else
          end

        end

        def get_client_attribute(data)
          client_attributes = {
            global_id:              data[:global_id]
            external_id:            data[:external_id]
            external_id_display:    data[:external_id_display]
            mosvy_number:           data[:mosvy_number]
            given_name:             data[:given_name]
            family_name:            data[:family_name]
            gender:                 data[:gender]
            date_of_birth:          data[:date_of_birth]
            village_id:             get_village(data[:location_current_village_code])
            reason_for_referral:    data[:reason_for_referral]
            protection_status:      data[:protection_status]
            external_case_worker_id:   data[:external_case_worker_id]
            external_case_worker_name: data[:external_case_worker_name]
            external_case_worker_mobile: data[:external_case_worker_mobile]
          }
        end

        def get_village(village_code)
          Village.find_by(code: village_code)&.id
        end
    end
  end
end
