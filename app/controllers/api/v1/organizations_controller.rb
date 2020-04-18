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
        # ClientsTransaction.initial(params[:transaction_id], clients_params)
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

        def update_or_referred_client(clients)
          clients.each do |client_attributes|
            client = Client.find_by(global_id: client_attributes['global_id'])
            begin
              if client
                # client.update_attributes(
                #   get_client_attribute(client_attributes)
                # )
              else
                binding.pry
                referral_attributes = get_referral_attribute(client_attributes)
                # Referral.create!(referral_attributes)
              end
            rescue Exception =>  e
              puts e
            end
          end
        end

        def get_client_attribute(attribute)
          client_attributes = {
            external_id:            attribute[:external_id],
            external_id_display:    attribute[:external_id_display],
            mosvy_number:           attribute[:mosvy_number],
            given_name:             attribute[:given_name],
            family_name:            attribute[:family_name],
            gender:                 attribute[:gender],
            date_of_birth:          attribute[:date_of_birth],
            reason_for_referral:    attribute[:reason_for_referral],
            external_case_worker_id:   attribute[:external_case_worker_id],
            external_case_worker_name: attribute[:external_case_worker_name],
            **get_village(attribute[:address_current_village_code])
          }
        end

        def get_referral_attribute(attribute)
          referral_attributes = {
            date_of_referral: Date.today,
            referred_to: attribute[:organization_name],
            referred_from: "MoSVY",
            referral_reason: attribute[:reason_for_referral],
            name_of_referee: attribute[:external_case_worker_name],
            referral_phone: attribute[:external_case_worker_mobile],
            referee_id: attribute[:external_case_worker_id], #This got to be internal case referree id
            client_name: "#{attribute[:given_name]} #{attribute[:family_name]}",
            consent_form: [], # default attachment
            client_id: nil, #Should we create New Schema for MoSVY?
            ngo_name: "MoSVY",
            client_global_id: ULID.generate,
            external_id: attribute[:external_id],
            external_id_display: attribute[:external_id_display],
            mosvy_number: attribute[:mosvy_number],
            external_case_worker_name: attribute[:external_case_worker_name],
            external_case_worker_id: attribute[:external_case_worker_id],
            services: attribute[:services]&.map{ |service| service[:name] }.join(", ") || "" #before client got a service we need to enroll client to a program stream
          }
        end

        def get_village(village_code)
          village = Village.find_by(code: village_code)
          if village
            { village_id: village.id, commune_id: village.commune&.id, district_id: village.commune.district&.id, province_id: village.commune.district.province&.id }
          else
            { village_id: nil }
          end
        end
    end
  end
end
