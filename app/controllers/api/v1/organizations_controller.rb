module Api
  module V1
    class OrganizationsController < Api::V1::BaseApiController
      skip_before_action :authenticate_user!
      before_action :authenticate_admin_user!, only: [:create, :update, :destroy]
      before_action :find_organization, only: [:update, :destroy]
      before_action :authenticate_api_admin_user!, :set_current_aut_user, only: [:clients, :upsert, :update_link]

      def index
        render json: Organization.visible.order(:created_at)
      end

      def clients
        sql = ''
        bulk_clients = []
        external_system_name = ExternalSystem.find_by(token: @current_user.email)&.name || ''
        date_time_param = Time.parse(params[:since_date]) if params[:since_date].present?
        Organization.only_integrated.pluck(:short_name).map do |short_name|
          Organization.switch_to short_name
          referred_clients, sql = get_sql_and_client_data(external_system_name, date_time_param)
          none_referred_clients = Client.find_by_sql(sql.squish)
          bulk_clients << referred_clients
          bulk_clients << JSON.parse(ActiveModel::Serializer::CollectionSerializer.new(none_referred_clients, each_serializer: ClientShareExternalSerializer, context: current_user).to_json)
        end
        Organization.switch_to 'public'
        render json: bulk_clients.flatten, root: :data
      end

      def upsert
        if params[:organization].present? && clients_params['organization_name'].present?
          if clients_params['global_id'].present?
            find_client_global_identiy
          else
            find_referral
          end
          Organization.switch_to 'public'
        else
          render json: { message: 'Record error. Please check OSCaR logs for details.' }, root: :data, status: :unprocessable_entity
        end
      end

      def find_client_global_identiy
        if GlobalIdentity.exists?(clients_params['global_id'])
          render_client_data
        else
          render json: { global_id: clients_params['global_id'], message: 'Record not found.' }, status: '404'
        end
      end

      def render_client_data
        client = nil
        global_identity = GlobalIdentity.find(clients_params['global_id'])
        short_name = global_identity.organizations.first&.short_name
        if short_name
          Organization.switch_to short_name
          client = Client.find_by(global_id: clients_params['global_id'])
          attributes = Client.get_client_attribute(clients_params, client.referral_source_category_id) if client
          if client && client.update_attributes(attributes)
            render json: { external_id: client.external_id, message: 'Record saved.' }
          else
            render json: { external_id: clients_params[:external_id], message: client.errors }, status: :unprocessable_entity
          end
        else
          find_referral
        end
      end

      def transaction
        if params[:tx_id].present?
          begin
            client_transaction = ClientsTransaction.find(params[:tx_id])
            render json: { transaction_id: params[:tx_id], items: client_transaction.items }, root: :data
          rescue StandardError => e
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
          render json: { error: client.errors, message: 'Record error. Please check OSCaR logs for details.' }, root: :data, status: :unprocessable_entity
        end
      end

      def create
        if org = Organization.create_and_build_tenant(organization_params)
          Organization.delay(queue: :priority).seed_generic_data(org.id, org.referral_source_category_name)
          render json: org, status: :ok
        else
          render json: { msg: org.errors }, status: :unprocessable_entity
        end
      rescue => e
        render json: e.message, status: :unprocessable_entity
      end

      def update
        if @organization.update_attributes(organization_params)
          render json: @organization, status: :ok
        else
          render json: { msg: org.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        head 204 if @organization.destroy
      end

      def check_duplication
        shared_clients = []
        return shared_clients unless ['given_name', 'family_name', 'local_family_name', 'local_given_name', 'date_of_birth', 'address_current_village_code', 'birth_province_id'].any?{|key| params.has_key?(key) }
        current_org = Apartment::Tenant.current
        Organization.switch_to 'shared'
        skip_orgs_percentage = Organization.skip_dup_checking_orgs.map { |val| "%#{val.short_name}%" }
        if skip_orgs_percentage.any?
          shared_clients = SharedClient.where.not('archived_slug ILIKE ANY ( array[?] ) AND duplicate_checker IS NOT NULL', skip_orgs_percentage).select(:duplicate_checker).pluck(:duplicate_checker)
        else
          shared_clients = SharedClient.where('duplicate_checker IS NOT NULL').select(:duplicate_checker).pluck(:duplicate_checker)
        end
        result = Client.check_for_duplication(params, shared_clients)

        Organization.switch_to current_org
        render json: { similar_fields: result ? 'Record was Found' : 'Record was not found' }
      end

      private

      def organization_params
        params.permit(:demo, :full_name, :short_name, :logo, :referral_source_category_name, :country, supported_languages: [])
      end

      def find_organization
        @organization = Organization.find(params[:id])
      end

      def clients_params
        params.require(:organization).permit(
          :global_id, :external_id, :external_id_display, :mosvy_number,
          :given_name, :family_name, :gender, :date_of_birth, :location_current_village_code,
          :address_current_village_code, :reason_for_referral, :reason_for_exiting,
          :organization_id, :organization_name, :external_case_worker_name,
          :external_case_worker_id, :external_case_worker_mobile, :external_case_worker_email,
          services: [:uuid, :name]
        )
      end

      def find_referral
        short_name = clients_params['organization_name']
        Organization.switch_to short_name
        referral_attributes = Referral.get_referral_attribute(clients_params)
        referral = Referral.find_by(external_id: clients_params[:external_id])
        if referral.nil?
          external_system = ExternalSystem.find_by(token: @current_user.email)
          external_system_id = external_system&.id
          external_system_name = external_system&.name
          referral = Referral.new(referral_attributes.merge(referred_from: external_system_name))
          if referral.save
            global_identity = GlobalIdentity.find_by(ulid: referral_attributes[:client_global_id])
            global_identity.external_system_global_identities.find_or_create_by(
              external_system_id: external_system_id,
              external_id: referral_attributes[:external_id],
              organization_name: short_name
            )
            render json: { external_id: clients_params[:external_id], message: 'Record saved.' }
          else
            render json: { external_id: clients_params[:external_id], message: referral.errors }, status: :unprocessable_entity
          end
        else
          render json: { external_id: clients_params[:external_id], message: 'Record saved.' }
        end
      end

      def authenticate_admin_user!
        authenticate_or_request_with_http_token do |token, _options|
          @current_user = AdminUser.find_by(token: token)
        end
      end

      def set_current_aut_user
        @current_user = current_api_admin_user
      end

      def get_sql_and_client_data(external_system_name, date_time_param)
        sql = "
                SELECT clients.*, districts.code district_code, communes.code commune_code, villages.code village_code
                FROM clients
                LEFT OUTER JOIN provinces ON provinces.id = clients.province_id
                LEFT OUTER JOIN districts ON districts.id = clients.district_id
                LEFT OUTER JOIN communes ON communes.id = clients.commune_id
                LEFT OUTER JOIN villages ON villages.id = clients.village_id

              ".squish
        clients = []
        if params.dig(:since_date).present?
          clients          = Client.referred_external(external_system_name).where('clients.created_at >= ? OR clients.updated_at >= ?', date_time_param, date_time_param).order('clients.updated_at DESC')
          referred_clients = JSON.parse ActiveModel::Serializer::CollectionSerializer.new(clients.distinct.to_a, each_serializer: OrganizationClientSerializer, context: current_user).to_json
          if clients.present?
            sql << " WHERE (DATE(clients.created_at) >= '#{date_time_param}' OR DATE(clients.updated_at) >= '#{date_time_param}') AND clients.id NOT IN (#{clients.ids.join(', ')}) ORDER BY clients.updated_at DESC"
          else
            sql << " WHERE (DATE(clients.created_at) >= '#{date_time_param}' OR DATE(clients.updated_at) >= '#{date_time_param}') ORDER BY clients.updated_at DESC"
          end
        else
          clients          = Client.referred_external(external_system_name).order('clients.updated_at DESC')
          referred_clients = JSON.parse ActiveModel::Serializer::CollectionSerializer.new(clients.distinct.to_a, each_serializer: OrganizationClientSerializer, context: current_user).to_json
          if clients.present?
            sql << " WHERE clients.id NOT IN (#{clients.ids.join(', ')}) ORDER BY clients.updated_at DESC"
          else
            sql << ' ORDER BY clients.updated_at DESC'
          end
        end
        [referred_clients, sql]
      end
    end
  end
end
