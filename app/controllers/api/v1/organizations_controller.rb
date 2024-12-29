module Api
  module V1
    class OrganizationsController < Api::V1::BaseApiController
      include ApplicationHelper

      skip_before_action :authenticate_user!
      before_action :authenticate_admin_user!, only: [:create, :update, :destroy]
      before_action :find_organization, only: [:update, :destroy]
      before_action :authenticate_api_admin_user!, :set_current_aut_user, only: [:clients, :upsert, :update_link]

      def index
        if Rails.env.production?
          render json: Organization.visible.order(:created_at)
        else
          render json: Organization.visible.order(:created_at), each_serializer: DemoOrganizationSerializer
        end
      end

      def listing
        ngos = mapping_ngos(select_ngos)
        render json: ngos
      end

      def clients
        sql = ''
        bulk_clients = []
        external_system_id, external_system_name = ExternalSystem.fetch_external_system_name(@current_user.email)
        date_time_param = Time.parse(params[:since_date]) if params[:since_date].present?
        end_date_param = Time.parse(params[:end_date]) if params[:end_date].present?
        Organization.only_integrated.pluck(:short_name).map do |short_name|
          Organization.switch_to short_name
          if end_date_param
            bulk_clients << find_historical_clients(external_system_name, date_time_param, end_date_param)
          else
            referred_clients, sql = get_sql_and_client_data(external_system_name, date_time_param)
            none_referred_clients = Client.find_by_sql(sql.squish)
            bulk_clients << referred_clients
            bulk_clients << JSON.parse(ActiveModel::ArraySerializer.new(none_referred_clients, each_serializer: ClientShareExternalSerializer, context: current_user).to_json)
          end
        end
        Organization.switch_to 'public'
        render json: bulk_clients.flatten, root: :data
      end

      def create
        org = Organization.new(organization_params)
        if org.save
          OrganizationWorker.perform_async(org.id)

          render json: org, status: :ok
        else
          render json: { msg: org.errors }, status: :unprocessable_entity
        end
      end

      def upsert
        if params[:organization].present? && clients_params['organization_name'].present?
          if clients_params['global_id'].present? && GlobalIdentity.find_by(ulid: clients_params['global_id'])
            Apartment::Tenant.switch! clients_params[:organization_name]
            object_saved = create_referral if clients_params[:is_referred].present? && clients_params[:is_referred]

            find_client_global_identiy(object_saved)
          else
            find_referral
          end
          Organization.switch_to 'public'
        else
          render json: { message: 'Record error. Please check OSCaR logs for details.' }, root: :data, status: :unprocessable_entity
        end
      end

      def find_client_global_identiy(object_saved)
        if (object_saved.nil? && GlobalIdentity.exists?(clients_params['global_id'])) || object_saved.valid? && GlobalIdentity.exists?(clients_params['global_id'])
          render_client_data
        elsif object_saved.errors.present?
          render json: { external_id: clients_params['external_id'], message: object_saved.errors }, status: :unprocessable_entity
        else
          render json: { global_id: clients_params['global_id'], message: 'Record not found.' }, status: '404'
        end
      end

      def render_client_data
        client = nil
        global_identity = GlobalIdentity.find(clients_params['global_id'])
        short_name = global_identity.organizations.first&.short_name
        if short_name
          Organization.switch_to short_name || clients_params[:organization_name]
          client = Client.find_by(global_id: clients_params['global_id'])
          attributes = Client.get_client_attribute(clients_params, client.referral_source_category_id) if client
          if client && client.update_attributes(attributes.except(:global_id))
            if clients_params['referral_status']
              check_referral_status(client, clients_params['referral_status'])
            else
              render json: { external_id: client.external_id, message: 'Record saved.' }
            end
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
          data = params[:data]
          global_ids = data.map { |hash| hash['global_id'] }
          data_hash = data.map { |pay_load| [pay_load['global_id'], [pay_load['external_id'], pay_load['external_id_display']]] }.to_h
          client_organizations = GlobalIdentityOrganization.where(global_id: global_ids).pluck(:global_id, :organization_id, :client_id).group_by(&:second)

          client_organizations.each do |ngo_id, client_ngos|
            ngo = Organization.find(ngo_id)
            Client.update_external_ids(ngo.short_name, client_ngos.map(&:last), data_hash)
          end

          Apartment::Tenant.switch('public')
          render json: { message: 'Record saved.' }, root: :data
        else
          render json: { error: client.errors, message: 'Record error. Please check OSCaR logs for details.' }, root: :data, status: :unprocessable_entity
        end
      end

      def update
        if @organization.update_attributes(organization_params)
          render json: @organization, status: :ok
        else
          render json: { msg: @organization.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        33054
      end

      def check_duplication
        shared_clients = []
        return shared_clients unless ['given_name', 'family_name', 'local_family_name', 'local_given_name', 'date_of_birth', 'address_current_village_code', 'birth_province_id'].any? { |key| params.has_key?(key) }
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

      def update_referral_status
        data = params[:data]
        data.each do |pay_load|
          global_id, referral_id, status = [pay_load['client_global_id'], pay_load['referral_id'], pay_load['referral_status']]

          global_identity_organization = GlobalIdentityOrganization.find_by(global_id: global_id)
          if global_identity_organization
            ngo = Organization.find(global_identity_organization.organization_id)
          else
            raise ActiveRecord::RecordNotFound
          end
          Apartment::Tenant.switch! ngo.short_name
          referral = Referral.find(referral_id)
          if referral
            external_system_id, external_system_name = ExternalSystem.fetch_external_system_name(params['uid'])
            next if referral.update_attributes(referral_status: status)

            raise ActiveRecord::RecordNotFound, (referral.errors.full_messages << "Referral status must be one of ['Accepted', 'Exited', 'Referred'].").join('. ')
          else
            raise ActiveRecord::RecordNotFound
          end
        end

        Apartment::Tenant.switch!('public')
        render json: { message: 'Record saved.' }, root: :data
      rescue ActiveRecord::RecordNotFound => e
        render json: { error: e.message, message: 'Record error. Please check OSCaR logs for details.' }, root: :data, status: :unprocessable_entity
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
          :level_of_risk, :is_referred, :referral_status,
          services: [:uuid, :name]
        )
      end

      def find_referral
        short_name = clients_params['organization_name']
        Organization.switch_to short_name
        referral_attributes = Referral.get_referral_attribute(clients_params)
        referral = Referral.find_by(external_id: clients_params[:external_id])
        if referral.nil?
          external_system_id, external_system_name = ExternalSystem.fetch_external_system_name(@current_user.email)
          referral = Referral.new(referral_attributes.merge(ngo_name: external_system_name, referred_from: external_system_name))
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
        elsif referral.present? && referral.client.nil?
          external_system_id, external_system_name = ExternalSystem.fetch_external_system_name(@current_user.email)
          referral = Referral.new(referral_attributes.merge(ngo_name: external_system_name, referred_from: external_system_name, client_global_id: referral.client_global_id))
          if referral.save
            render json: { external_id: clients_params[:external_id], message: 'Record saved.' }
          else
            render json: { external_id: clients_params[:external_id], message: referral.errors }, status: :unprocessable_entity
          end
        else
          message = {}
          message['global_id'] = 'global_id must exist.' if clients_params['global_id'].blank?
          message['referral_status'] = 'referral_status must be present.' if clients_params['global_id'].blank?

          render json: { external_id: clients_params[:external_id], message: 'Record was found.', errors: message }, status: :unprocessable_entity
        end
      end

      def create_referral
        external_system_id, external_system_name = ExternalSystem.fetch_external_system_name(@current_user.email)
        referral_attributes = Referral.get_referral_attribute(clients_params)
        client = Client.find_by(global_id: referral_attributes[:client_global_id])

        if client
          referee = client.referee || client.received_by || client.users.last
          referral = Referral.new(
            referral_attributes.merge(
              ngo_name: external_system_name,
              referred_from: external_system_name,
              slug: client&.slug,
              referee_id: referee.id
            )
          )

          if ['Accepted', 'Exited', 'Referred'].include?(clients_params['referral_status']) && referral.save
            global_identity = GlobalIdentity.find_by(ulid: referral_attributes[:client_global_id])
            global_identity.external_system_global_identities.find_or_create_by(
              external_system_id: external_system_id,
              external_id: referral_attributes[:external_id],
              organization_name: clients_params[:organization_name]
            )
            global_identity
          else
            referral.save
            referral
          end
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

      def get_sql_and_client_data(external_system_name, since_date)
        conditional_sql = "(TRIM(CONCAT(clients.given_name, clients.local_given_name)) != '' AND TRIM(CONCAT(clients.family_name, clients.local_family_name)) != '') AND clients.gender != '' AND clients.date_of_birth IS NOT NULL"
        sql = "
                SELECT clients.*, districts.code district_code, communes.code commune_code, villages.code village_code
                FROM clients
                LEFT OUTER JOIN provinces ON provinces.id = clients.province_id
                LEFT OUTER JOIN districts ON districts.id = clients.district_id
                LEFT OUTER JOIN communes ON communes.id = clients.commune_id
                LEFT OUTER JOIN villages ON villages.id = clients.village_id
                WHERE (#{conditional_sql})
              ".squish
        clients = []
        if params.dig(:since_date).present?
          clients = Client.referred_external(external_system_name).where("#{conditional_sql} AND (clients.created_at >= ? OR clients.updated_at >= ?)", since_date, since_date).order('clients.updated_at DESC')
          referred_clients = JSON.parse ActiveModel::ArraySerializer.new(clients.distinct.to_a, each_serializer: OrganizationClientSerializer, context: current_user).to_json
          if clients.present?
            sql << " AND (DATE(clients.created_at) >= '#{since_date}' OR DATE(clients.updated_at) >= '#{since_date}') AND clients.id NOT IN (#{clients.ids.join(', ')}) ORDER BY clients.updated_at DESC"
          else
            sql << " AND (DATE(clients.created_at) >= '#{since_date}' OR DATE(clients.updated_at) >= '#{since_date}') ORDER BY clients.updated_at DESC"
          end
        else
          clients = Client.referred_external(external_system_name).where(conditional_sql).order('clients.updated_at DESC')
          referred_clients = JSON.parse ActiveModel::ArraySerializer.new(clients.distinct.to_a, each_serializer: OrganizationClientSerializer, context: current_user).to_json
          if clients.present?
            sql << " AND clients.id NOT IN (#{clients.ids.join(', ')}) ORDER BY clients.updated_at DESC"
          else
            sql << ' ORDER BY clients.updated_at DESC'
          end
        end
        [referred_clients, sql]
      end

      def find_historical_clients(external_system_name, since_date, end_date)
        sql = "
                SELECT clients.*, districts.code district_code, communes.code commune_code, villages.code village_code
                FROM clients
                LEFT OUTER JOIN provinces ON provinces.id = clients.province_id
                LEFT OUTER JOIN districts ON districts.id = clients.district_id
                LEFT OUTER JOIN communes ON communes.id = clients.commune_id
                LEFT OUTER JOIN villages ON villages.id = clients.village_id
                WHERE ((TRIM(CONCAT(clients.given_name, clients.local_given_name)) != '' AND TRIM(CONCAT(clients.family_name, clients.local_family_name)) != '') AND clients.gender != '' AND clients.date_of_birth IS NOT NULL) AND
              ".squish
        clients = []

        sql << " clients.created_at BETWEEN '#{since_date}' AND '#{end_date}' ORDER BY clients.created_at asc"
        clients = Client.find_by_sql(sql)
        JSON.parse ActiveModel::ArraySerializer.new(clients.to_a.uniq, each_serializer: ClientShareExternalSerializer, context: current_user).to_json
      end

      def create_second_referral
        external_system_id, external_system_name = ExternalSystem.fetch_external_system_name(@current_user.email)
        referral = Referral.new(referral_attributes.merge(referred_from: external_system_name))
      end

      def check_referral_status(client, status)
        if ['Accepted', 'Exited', 'Referred'].include?(status)
          external_system_id, external_system_name = ExternalSystem.fetch_external_system_name(@current_user.email)
          client.referrals.received.get_external_systems(external_system_name).last&.update_referral_status(status)
          client.referrals.delivered.get_external_systems(external_system_name).last&.update_referral_status(status)
          render json: { external_id: client.external_id, message: 'Record saved.' }
        else
          render json: { external_id: client.external_id, message: "Referral status must be one of ['Accepted', 'Exited', 'Referred']." }, status: :unprocessable_entity
        end
      end
    end
  end
end
