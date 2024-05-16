class CallsController < AdminController
  load_and_authorize_resource find_by: :id
  include ApplicationHelper

  before_action :set_association, only: [:new, :show]
  before_action :country_address_fields, only: [:new]
  before_action :find_call, :find_associations, only: [:edit, :update]

  def index
    @query_json = params[:query_builder_json].presence
    query_string = params[:query_string]
    query_string = Call.mapping_query_field(query_string) if @query_json.present?
    @calls_grid = CallsGrid.new(params[:calls_grid]) do |scope|
      if (@query_json)
        calls = scope.joins('LEFT OUTER JOIN call_protection_concerns ON call_protection_concerns.call_id = calls.id LEFT OUTER JOIN protection_concerns ON protection_concerns.id = call_protection_concerns.protection_concern_id')
        calls = calls.joins('LEFT OUTER JOIN call_necessities ON call_necessities.call_id = calls.id LEFT OUTER JOIN necessities ON necessities.id = call_necessities.necessity_id')
        calls.where(query_string).distinct.order(:created_at)
      else
        scope.order(:created_at)
      end
    end
    respond_to do |f|
      f.html do
        @results = @calls_grid.assets.size
        @calls_grid = @calls_grid.scope { |scope| scope.page(params[:page]).per(20) }
        @query_json
      end
      f.xls do
        send_data @calls_grid.to_xls, filename: "calls_report-#{Time.now}.xls"
      end
    end
  end

  def new
    @referee = Referee.new
    @carer = Carer.new
    @client = Client.new
    @referees = Referee.all
    @providing_update_clients = Client.accessible_by(current_ability).map { |client| { label: client.name, value: client.id } }
    @necessities = Necessity.order(:created_at)
    @protection_concerns = ProtectionConcern.order(:created_at)
    @call = Call.new
  end

  def show
    @call = Call.find(params[:id])
    @referee = @call.referee
    @clients = @call.clients.map { |client| { slug: client.slug, full_name: client.en_and_local_name, gender: client.gender } }
    @locale = params[:locale]
    @call_necessity_ids = @call.necessity_ids
    @call_protection_concern_ids = @call.protection_concern_ids
  end

  def edit
  end

  def update
    if @call.update_attributes(call_params)
      redirect_to call_path(@call), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def edit_referee
    @referees = Referee.all
    @call = Call.find(params[:call_id])
    @referee = @call.referee

    @current_provinces = Province.order(:name)
    @referee_districts = @referee&.province&.districts || []
    @referee_communes = @referee&.province&.districts&.flat_map(&:communes) || []
    @referee_villages = @referee_communes&.flat_map(&:villages) || []
    @address_types = Client::ADDRESS_TYPES.map { |type| { label: type, value: type.downcase } }
  end

  def update_referee
  end

  private

  def call_params
    params.require(:call).permit(:answered_call, :called_before, :childsafe_agent, :receiving_staff_id,
                                 :date_of_call, :start_datetime,
                                 :information_provided, :not_a_phone_call, :other_more_information, :brief_note_summary,
                                 necessity_ids: [], protection_concern_ids: [])
  end

  def set_association
    @agencies = Agency.order(:name)
    @donors = Donor.order(:name)
    @users = User.non_strategic_overviewers.order(:first_name, :last_name).map { |user| [user.name, user.id] }

    subordinate_users = current_user.all_subordinates.ids
    if current_user.admin? || current_user.hotline_officer?
      @families = Family.order(:name)
    elsif current_user.manager?
      exited_client_ids = exited_clients(subordinate_users)
      family_ids = current_user.families.ids
      family_ids += User.joins(:clients).where(id: subordinate_users).where.not(clients: { current_family_id: nil }).select('clients.current_family_id AS client_current_family_id').map(&:client_current_family_id)
      family_ids += Client.where(id: exited_client_ids).pluck(:current_family_id)
      clients = Client.accessible_by(current_ability)
      family_ids += clients.where(user_id: current_user.id).pluck(:current_family_id)

      @families = Family.where(id: family_ids)
    elsif current_user.case_worker?
      family_ids = current_user.families.ids
      family_ids += User.joins(:clients).where(id: current_user.id).where.not(clients: { current_family_id: nil }).select('clients.current_family_id AS client_current_family_id').map(&:client_current_family_id)
      @families = Family.where(id: family_ids)
    end

    @relation_to_caller = Client::RELATIONSHIP_TO_CALLER.map { |relationship| { label: relationship, value: relationship.downcase } }
    @client_relationships = Carer::CLIENT_RELATIONSHIPS.map { |relationship| { label: relationship, value: relationship.downcase } }
    @address_types = Client::ADDRESS_TYPES.map { |type| { label: type, value: type.downcase } }
    @phone_owners = Client::PHONE_OWNERS.map { |owner| { label: owner, value: owner.downcase } }
    @referral_source = []
    @referral_source_category = referral_source_name(ReferralSource.parent_categories)
  end

  def country_address_fields
    selected_country = Setting.first.try(:country_name) || params[:country]
    current_org = Organization.current.short_name
    Organization.switch_to 'shared'
    @birth_provinces = []
    Organization.pluck(:country).uniq.reject(&:blank?).map { |country| @birth_provinces << [country.titleize, Province.country_is(country).map { |p| [p.name, p.id] }] }
    Organization.switch_to current_org

    @current_provinces = Province.order(:name)

    @districts = []
    @subdistricts = []
    @communes = []
    @villages = []

    province_ids = Referee.where.not(province_id: nil).pluck(:province_id).uniq
    districts = District.where(province_id: province_ids)
    communes = Commune.where(district_id: districts.ids)
    villages = Village.where(commune_id: communes.ids)
    @referee_districts = districts
    @referee_communes = communes
    @referee_villages = villages

    @carer_districts = []
    @carer_communes = []
    @carer_villages = []
  end

  def exited_clients(user_ids)
    client_ids = CaseWorkerClient.where(id: PaperTrail::Version.where(item_type: 'CaseWorkerClient', event: 'create').joins(:version_associations).where(version_associations: { foreign_key_name: 'user_id', foreign_key_id: user_ids }).distinct.map(&:item_id)).pluck(:client_id).uniq
    Client.where(id: client_ids, status: 'Exited').ids
  end

  def find_associations
    @users = User.non_strategic_overviewers.order(:first_name, :last_name).map { |user| [user.name, user.id] }
    @necessities = Necessity.order(:created_at)
    @protection_concerns = ProtectionConcern.order(:created_at)
  end

  def find_call
    @call = Call.find(params[:id])
  end
end
