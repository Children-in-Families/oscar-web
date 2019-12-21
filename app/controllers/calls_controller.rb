class CallsController < AdminController
  load_and_authorize_resource find_by: :slug, except: :quantitative_case


  before_action :set_association, except: [:index, :destroy, :version]





  def new
    if params[:referral_id].present?
      current_org = Organization.current
      referral_source_id = find_referral_source_by_referral

      Organization.switch_to 'shared'
      attributes = SharedClient.find_by(archived_slug: @referral.slug).try(:attributes) || SharedClient.find_by(slug: @referral.slug).try(:attributes)
      if attributes.present?
        attributes = attributes.except('duplicate_checker')
        attributes = fetch_referral_attibutes(attributes, referral_source_id)
      else
        attributes
      end
      Organization.switch_to current_org.short_name
      @client = Client.new(attributes)
    else
      @client = Client.new
    end
  end

  def create
    @client = Client.new(client_params)
    if @client.save
      if params[:clientConfirmation] == 'createNewFamilyRecord'
        redirect_to new_family_path(children: [@client.id])
      else
        redirect_to @client, notice: t('.successfully_created')
      end
    else
      render :new
    end
  end

  def quantitative_case
    if params[:id].blank?
      render json: QuantitativeCase.all, root: :data
    else
      render json: QuantitativeCase.quantitative_cases_by_type(params[:id]), root: :data
    end
  end

  private

  def client_params
    remove_blank_exit_reasons
    params.require(:client)
          .permit(
            :slug, :archived_slug, :code, :name_of_referee, :main_school_contact, :rated_for_id_poor, :what3words, :status, :country_origin,
            :kid_id, :assessment_id, :given_name, :family_name, :local_given_name, :local_family_name, :gender, :date_of_birth,
            :birth_province_id, :initial_referral_date, :referral_source_id, :telephone_number,
            :referral_phone, :received_by_id, :followed_up_by_id,
            :follow_up_date, :school_grade, :school_name, :current_address,
            :house_number, :street_number, :suburb, :description_house_landmark, :directions, :street_line1, :street_line2, :plot, :road, :postal_code, :district_id, :subdistrict_id,
            :has_been_in_orphanage, :has_been_in_government_care,
            :relevant_referral_information, :province_id, :current_family_id,
            :state_id, :township_id, :rejected_note, :live_with, :profile, :remove_profile,
            :gov_city, :gov_commune, :gov_district, :gov_date, :gov_village_code, :gov_client_code,
            :gov_interview_village, :gov_interview_commune, :gov_interview_district, :gov_interview_city,
            :gov_caseworker_name, :gov_caseworker_phone, :gov_carer_name, :gov_carer_relationship, :gov_carer_home,
            :gov_carer_street, :gov_carer_village, :gov_carer_commune, :gov_carer_district, :gov_carer_city, :gov_carer_phone,
            :gov_information_source, :gov_referral_reason, :gov_guardian_comment, :gov_caseworker_comment, :commune_id, :village_id, :referral_source_category_id, :referee_id, :carer_id,
            interviewee_ids: [],
            client_type_ids: [],
            user_ids: [],
            agency_ids: [],
            donor_ids: [],
            quantitative_case_ids: [],
            custom_field_ids: [],
            family_ids: [],
            tasks_attributes: [:name, :domain_id, :completion_date],
            client_needs_attributes: [:id, :rank, :need_id],
            client_problems_attributes: [:id, :rank, :problem_id]
          )
  end

  def remove_blank_exit_reasons
    return if params[:client][:exit_reasons].blank?
    params[:client][:exit_reasons].reject!(&:blank?)
  end

  def set_association
    @agencies        = Agency.order(:name)
    @donors          = Donor.order(:name)
    @users           = User.non_strategic_overviewers.order(:first_name, :last_name)
    @interviewees    = Interviewee.order(:created_at)
    @client_types    = ClientType.order(:created_at)
    @needs           = Need.order(:created_at)
    @problems        = Problem.order(:created_at)

    subordinate_users = User.where('manager_ids && ARRAY[:user_id] OR id = :user_id', { user_id: current_user.id }).map(&:id)
    if current_user.admin?
      @families        = Family.order(:name)
    elsif current_user.manager?
      family_ids = current_user.families.ids
      User.where(id: subordinate_users).each do |user|
        user.clients.each do |client|
          family_ids << client.family.try(:id)
        end
      end
      Client.where(id: exited_clients(subordinate_users)).each do |client|
        family_ids << client.family.try(:id)
      end
      current_user.clients.each do |client|
        family_ids << client.family.try(:id)
      end
      @families = Family.where(id: family_ids)
    elsif current_user.case_worker?
      family_ids = current_user.families.ids
      current_user.clients.each do |client|
        family_ids << client.family.try(:id)
      end
      @families = Family.where(id: family_ids)
    end

    # @carer   = @client.carer.present? ? @client.carer : Carer.new
    # @referee = @client.referee.present? ? @client.referee : Referee.new
    @carer     = Carer.new
    @referee   = Referee.new
    @referee_relationships = Client::REFEREE_RELATIONSHIPS.map{|relationship| {label: relationship, value: relationship.downcase}}
    @client_relationships = Carer::CLIENT_RELATIONSHIPS.map{|relationship| {label: relationship, value: relationship.downcase}}
    @address_types = Client::ADDRESS_TYPES.map{|type| {label: type, value: type.downcase}}
    @phone_owners = Client::PHONE_OWNERS.map{|owner| {label: owner, value: owner.downcase}}
    @referral_source = []
    @referral_source_category = referral_source_name(ReferralSource.parent_categories)
    country_address_fields
  end

  def referral_source_name(referral_source)
    if I18n.locale == :km
      referral_source.map{|ref| [ref.name, ref.id] }
    else
      referral_source.map do |ref|
        if ref.name_en.blank?
          [ref.name, ref.id]
        else
          [ref.name_en, ref.id]
        end
      end
    end
  end

  def country_address_fields
    selected_country = Setting.first.try(:country_name) || params[:country]
    current_org = Organization.current.short_name
    Organization.switch_to 'shared'
    @birth_provinces = []
    ['Cambodia', 'Thailand', 'Lesotho', 'Myanmar', 'Uganda'].map{ |country| @birth_provinces << [country, Province.country_is(country.downcase).map{|p| [p.name, p.id] }] }
    Organization.switch_to current_org
    @current_provinces        = Province.order(:name)
    @states                   = State.order(:name)
    # @townships                = @client.state.present? ? @client.state.townships.order(:name) : []
    # @districts                = @client.province.present? ? @client.province.districts.order(:name) : []
    # @subdistricts             = @client.district.present? ? @client.district.subdistricts.order(:name) : []
    # @communes                 = @client.district.present? ? @client.district.communes.order(:code) : []
    # @villages                 = @client.commune.present? ? @client.commune.villages.order(:code) : []

    # @referee_districts                = @client.referee.try(:province).present? ? @client.referee.province.districts.order(:name) : []
    # @referee_communes                 = @client.referee.try(:district).present? ? @client.referee.district.communes.order(:code) : []
    # @referee_villages                 = @client.referee.try(:commune).present? ? @client.referee.commune.villages.order(:code) : []

    # @carer_districts                = @client.carer.try(:province).present? ? @client.carer.province.districts.order(:name) : []
    # @carer_communes                 = @client.carer.try(:district).present? ? @client.carer.district.communes.order(:code) : []
    # @carer_villages                 = @client.carer.try(:commune).present? ? @client.carer.commune.villages.order(:code) : []
    @townships                = []
    @districts                = []
    @subdistricts             = []
    @communes                 = []
    @villages                 = []

    @referee_districts                = []
    @referee_communes                 = []
    @referee_villages                 = []

    @carer_districts                = []
    @carer_communes                 = []
    @carer_villages                 = []
  end

  def find_referral_source_by_referral
    referral_source_org = Organization.find_by(short_name: @referral.referred_from).full_name
    ReferralSource.find_by(name: "#{referral_source_org} - OSCaR Referral").try(:id)
  end

  def fetch_referral_attibutes(attributes, referral_source_id)
    attributes.merge!({
      initial_referral_date: @referral.date_of_referral,
      referral_phone: @referral.referral_phone,
      relevant_referral_information: @referral.referral_reason,
      name_of_referee: @referral.name_of_referee,
      referral_source_id: referral_source_id
    })
  end

  def exited_clients(users)
    client_ids = []
    users.each do |user|
      PaperTrail::Version.where(item_type: 'CaseWorkerClient', event: 'create').where_object_changes(user_id: user).each do |version|
        next if version.changeset[:user_id].last != user
        client_id = version.changeset[:client_id].last
        next if !Client.find_by(id: client_id).presence.try(:exit_ngo?)
        client_ids << client_id if client_id.present?
      end
    end
    client_ids.uniq
  end
end
