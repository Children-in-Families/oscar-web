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
          if params.dig(:since_date).present? && params.dig(:referred_external).present?
            clients = JSON.parse ActiveModel::ArraySerializer.new(Client.where("created_at >= ? AND status = ?", "#{params[:since_date]}", 'Referred').limit(10).to_a, each_serializer: OrganizationClientSerializer).to_json
          elsif params.dig(:since_date).present?
            clients = JSON.parse ActiveModel::ArraySerializer.new(Client.where("created_at >= ?", "#{params[:since_date]}").limit(10).to_a, each_serializer: OrganizationClientSerializer).to_json
          elsif params.dig(:referred_external).present?
            clients = JSON.parse ActiveModel::ArraySerializer.new(Client.where(status: 'Referred').limit(10).to_a, each_serializer: OrganizationClientSerializer).to_json
          else
            clients = JSON.parse ActiveModel::ArraySerializer.new(Client.limit(10).to_a, each_serializer: OrganizationClientSerializer).to_json
          end

          bulk_clients << clients
        end
        Organization.switch_to 'public'

        render json: bulk_clients.flatten.compact, root: :data
      end

      def upsert
        respone_messages = []
        if params[:transaction_id].present?
          clients_params[:organization].group_by{ |data| data[:organization_name] }.each do |short_name, data|
            Organization.switch_to short_name
            respone_messages << update_or_referred_client(data)
          end

          ClientsTransaction.initial(params[:transaction_id], respone_messages.flatten.compact)
          Organization.switch_to 'public'
          render json: { message: 'The data has been sent successfully.' }, root: :data
        else
          render json: { message: 'Record error. Please check OSCaR logs for details.' }, root: :data, status: :unprocessable_entity
        end
      end

      def transaction
        if params[:tx_id].present?
          begin
            client_transaction = ClientsTransaction.find(params[:tx_id])
            render json: { transaction_id: params[:tx_id], items: client_transaction.items }, root: :data
          rescue Exception => e
            render json: { message: 'Record error. Please check OSCaR logs for details.' }, root: :data, status: '500'
          end
        else
          render json: { message: 'Record error. Please check OSCaR logs for details.' }, root: :data, status: :unprocessable_entity
        end
      end

      def update_link
        if params[:data].present?
          data       = params[:data]
          global_ids = data.map(&:values).map(&:last)
          data_hash  = data.map{ |pay_load| [pay_load[:global_id], [pay_load[:external_id], pay_load[:external_id_display]] ] }.to_h
          client_organizations = GlobalIdentityOrganization.where(global_id: global_ids).pluck(:global_id, :organization_id, :client_id).group_by(&:second)
          client_organizations.each do |ngo_id, client_ngos|
            ngo = Organization.find(ngo_id)
            Organization.switch_to ngo.short_name
            Client.where(id: client_ngos.map(&:last)).each do |client|
              client.external_id = data_hash[client.global_id].first
              client.external_id_display = data_hash[client.global_id].last
              client.save
            end
          end
          render json: { message: 'Record saved.' }, root: :data
        else
          render json: { message: 'Record error. Please check OSCaR logs for details.' }, root: :data, status: :unprocessable_entity
        end
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
                :external_case_worker_id, :external_case_worker_mobile, :protection_status,
                services: [:id, :name]
              ]
            )
        end

        def update_or_referred_client(clients)
          messages = []
          clients.each do |client_attributes|
            client = nil
            begin
              if client_attributes['global_id'].present?
                global_identity = GlobalIdentity.find(client_attributes['global_id'])
                client = global_identity.global_identity_organizations.last&.client
              end
              if client
                attributes = client.get_client_attribute(client_attributes)
                client.update_attributes(attributes)
                messages << { external_id: client_attributes[:external_id], status: "200", message: 'Record saved.' }
              else
                referral_attributes = Referral.get_referral_attribute(client_attributes)
                referral = Referral.find_by(external_id: client_attributes[:external_id])
                unless referral
                  if Referral.create!(referral_attributes)
                    global_identity = GlobalIdentity.find(referral_attributes[:client_global_id])
                    external_system_id = ExternalSystem.find_by(token: @current_user.email)&.id
                    global_identity.external_system_global_identities.create!(
                      external_system_id: external_system_id,
                      external_id: referral_attributes[:external_id]
                    )
                    messages << { object_id: client_attributes[:external_id], status: "200", message: 'Record saved.' }
                  end
                end
              end
            rescue Exception =>  error
              messages << { external_id: client_attributes[:external_id], status: "500", message: "Record error. Please check OSCaR logs for details." }
            end
          end
          messages
        end
    end
  end
end
