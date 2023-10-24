class ClientsController < AdminController
  load_and_authorize_resource find_by: :slug, except: [:quantitative_case, :destroy, :restore]
  include ApplicationHelper
  include ClientAdvancedSearchesConcern
  include ClientGridOptions
  include CacheHelper

  before_action :assign_active_client_prams, only: :index
  before_action :format_search_params, only: [:index]
  before_action :get_quantitative_fields, :get_hotline_fields, :hotline_call_column, only: [:index]
  before_action :find_params_advanced_search, :get_custom_form, :get_program_streams, only: [:index]
  before_action :get_custom_form_fields, :program_stream_fields, :custom_form_fields, :client_builder_fields, only: [:index]
  before_action :basic_params, if: :has_params?, only: [:index]
  before_action :build_advanced_search, only: [:index]
  before_action :fetch_advanced_search_queries, only: [:index]

  before_action :find_client, only: [:show, :edit, :update, :custom_fields]
  before_action :assign_client_attributes, only: [:show, :edit]
  before_action :set_association, except: [:index, :destroy, :restore, :archive, :archived, :version, :welcome, :load_client_table_summary, :load_statistics_data]
  before_action :choose_grid, only: [:index]
  before_action :quantitative_type_editable, only: [:edit, :update, :new, :create]
  before_action :quantitative_type_readable
  before_action :validate_referral, only: [:new, :edit]

  def welcome
    choose_grid
  end

  def archived
    @clients = Client.only_deleted.accessible_by(current_ability).includes(:archived_by)
  end

  def custom_fields
    if current_user.admin? || current_user.strategic_overviewer?
      @available_editable_forms = CustomField.all
      @readable_forms = @client.custom_field_properties
    else
      @available_editable_forms = CustomField.where(id: current_user.custom_field_permissions.where(editable: true).pluck(:custom_field_id))
      @readable_forms = @client.custom_field_properties.where(custom_field_id: current_user.custom_field_permissions.where(readable: true).pluck(:custom_field_id))
    end
  end

  def index
    @client_default_columns = Setting.cache_first.client_default_columns
    if params[:advanced_search_id]
      current_advanced_search = AdvancedSearch.find(params[:advanced_search_id])
      @visible_fields = current_advanced_search.field_visible
    end

    if has_params? || params[:advanced_search_id].present? || params[:client_advanced_search].present?
      advanced_search
    else
      client_columns_visibility
      respond_to do |f|
        f.html do
          # @client_grid is invoked from ClientGridOptions#choose_grid
          client_grid = @client_grid.scope { |scope| scope.accessible_by(current_ability) }
          @results = client_grid.assets
          $client_data = @clients
          @client_grid = @client_grid.scope { |scope| scope.accessible_by(current_ability).order(:id).page(params[:page]).per(20) }
        end
        f.xls do
          @client_grid.scope { |scope| scope.accessible_by(current_ability) }
          @client_grid.params = params.to_unsafe_h.dup.deep_symbolize_keys

          export_client_reports
          send_data @client_grid.to_xls, filename: "client_report-#{Time.now}.xls"
        end
      end
    end
  end

  def show
    respond_to do |format|
      format.html do
        Referral.where(id: params[:referral_id]).update_all(client_id: @client.id, saved: true) if params[:referral_id].present?

        @referees = Referee.cache_none_anonymous.map { |referee| { value: referee.id, text: referee.name } }
        @current_provinces = Province.pluck(:id, :name).map { |id, name| { value: id, text: name } }
        @birth_provinces = @birth_provinces.map { |parent, children| children.map { |t, v| { value: v, text: t } } }.flatten

        custom_field_ids = @client.custom_field_properties.pluck(:custom_field_id)
        if current_user.admin? || current_user.strategic_overviewer?
          available_editable_forms = CustomField.all
        else
          available_editable_forms = CustomField.where(id: current_user.custom_field_permissions.where(editable: true).pluck(:custom_field_id))
        end

        @free_client_forms = available_editable_forms.client_forms.where(hidden: false).not_used_forms(custom_field_ids).order_by_form_title

        initial_visit_client
        enter_ngos = @client.enter_ngos
        exit_ngos = @client.exit_ngos
        cps_enrollments = @client.client_enrollments.includes(:leave_program, :program_stream)
        cps_leave_programs = LeaveProgram.joins(:client_enrollment).where('client_enrollments.client_id = ?', @client.id)
        referrals = @client.referrals
        @case_histories = (enter_ngos + exit_ngos + cps_enrollments + cps_leave_programs + referrals).sort { |current_record, next_record| -([current_record.new_date, current_record.created_at] <=> [next_record.new_date, next_record.created_at]) }
        @internal_referrals = @client.internal_referrals.joins(:program_streams).select('DISTINCT ON (internal_referrals.id, program_streams.id) internal_referrals.id, internal_referrals.referral_date, internal_referrals.client_id, program_streams.name program_name, internal_referrals.created_at')
      end

      format.pdf do
        form = params[:form]
        form_title = t(".government_form_#{form}")
        client_name = @client.en_and_local_name
        pdf_name = "#{client_name} - #{form_title}"
        render pdf: pdf_name,
               template: 'clients/show.pdf.haml',
               page_size: 'A4',
               layout: 'pdf_design.html.haml',
               show_as_html: params.key?('debug'),
               header: { html: { template: 'government_reports/pdf/header.pdf.haml' } },
               footer: { html: { template: 'government_reports/pdf/footer.pdf.haml' }, right: '[page] of [topage]' },
               margin: { left: 0, right: 0, top: 10 },
               dpi: '72',
               disposition: 'inline'
      end
    end
  end

  def new
    if params[:referral_id].present?
      current_org = Organization.current
      find_referral_by_params
      referral_source_id = find_referral_source_by_referral
      referral_attr = @referral.attributes
      attributes = {}
      Organization.switch_to 'shared'
      attributes = SharedClient.find_by(archived_slug: referral_attr['slug'])&.attributes || SharedClient.find_by(slug: referral_attr['slug'])&.attributes
      if attributes.present?
        attributes = attributes.except('id', 'duplicate_checker')
        attributes = fetch_referral_attibutes(attributes, referral_source_id, referral_attr)
      else
        attributes.present? ? attributes.symbolize_keys : attributes
      end
      Organization.switch_to current_org.short_name
      if @referral
        client_names = @referral.client_name.split(' ')
        given_name, family_name = [(client_names[0] || ''), (client_names[1] || '')]
        local_family_name, local_given_name = (@referral.client_name.scan(/\(((?:[^\)\(]++))\)/).first && @referral.client_name.scan(/\(((?:[^\)\(]++))\)/).first.split(' ')) || ['', '']
        client_attr = { given_name: given_name, family_name: family_name,
                       local_given_name: '', local_family_name: '',
                       gender: @referral.client_gender, reason_for_referral: @referral.referral_reason,
                       date_of_birth: @referral.client_date_of_birth,
                       referral_source_id: referral_source_id,
                       initial_referral_date: @referral.date_of_referral,
                       from_referral_id: @referral.id }

        if attributes.present?
          attributes = Client.get_client_attribute(@referral.attributes).merge(client_attr).merge(attributes)
        else
          attributes = Client.get_client_attribute(@referral.attributes).merge(client_attr)
        end
      end
      @client = Client.new(attributes)
    else
      new_params = {}
      if params.has_key?(:name)
        first_name, last_name = params[:name] ? params[:name].split(' ').reverse : ['', '']
        new_params = params.permit(:gender, :date_of_birth, :client_phone)
      end

      @client = Client.new(new_params.merge(local_given_name: first_name, local_family_name: last_name, gender: new_params[:gender]&.downcase))
      @risk_assessment = @client.build_risk_assessment
      @risk_assessment.tasks.build
    end
    @custom_data = CustomData.first
    @client_custom_data = @client.client_custom_data
    @referral_source_category = referral_source_name(ReferralSource.parent_categories, @client)
  end

  def edit
    attributes = @client.attributes
    if params[:referral_id].present?
      find_referral_by_params
      referral_source_id = find_referral_source_by_referral
      attributes = fetch_referral_attibutes(attributes, referral_source_id)
      attributes.merge!({ status: 'Referred' })
      @client.attributes = attributes
    end

    @risk_assessment = @client.risk_assessment || @client.build_risk_assessment
    @custom_data = CustomData.first
    client_custom_data = @client.client_custom_data
    if client_custom_data
      form_builder_attachments = client_custom_data.try(:form_builder_attachments).map do |form_builder_attachment|
        form_builder_attachment.file.map(&:to_json)
        [form_builder_attachment.name, { id: form_builder_attachment.id, files: form_builder_attachment.file.map(&:to_json).map { |file| JSON.parse(file) } }]
      end
      @client_custom_data_properties = (client_custom_data.properties || {}).merge(form_builder_attachments.to_h)
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

  def update
    new_params = @client.current_family_id ? client_params : client_params.except(:family_ids)
    if @client.update_attributes(client_params.except(:family_ids))
      if params[:client][:assessment_id]
        @assessment = Assessment.find(params[:client][:assessment_id])
        redirect_to client_assessment_path(@client, @assessment), notice: t('.assessment_successfully_created')
      else
        redirect_to @client, notice: t('.successfully_updated')
      end
    else
      render :edit
    end
  end

  def restore
    client = Client.only_deleted.friendly.find(params[:id])
    client.recover
    redirect_to client, notice: t('.successfully_restored')
  end

  def destroy
    @client = Client.only_deleted.friendly.find(params[:id])

    ActiveRecord::Base.transaction do
      if @client.destroy
        begin
          EnterNgo.with_deleted.where(client_id: @client.id).each(&:destroy_fully!)
          ClientEnrollment.with_deleted.where(client_id: @client.id).delete_all
          Case.where(client_id: @client.id).delete_all
          CaseWorkerClient.with_deleted.where(client_id: @client.id).each(&:destroy_fully!)
          Task.with_deleted.where(client_id: @client.id).each(&:destroy_fully!)
          ExitNgo.with_deleted.where(client_id: @client.id).each(&:destroy_fully!)

          redirect_to archived_clients_path, notice: t('.successfully_deleted')
        rescue => exception
          raise ActiveRecord::Rollback
        end
      else
        messages = "Can't delete client because the client is still attached with family"
        redirect_to archived_clients_path, alert: messages
      end
    end
  rescue ActiveRecord::Rollback => exception
    redirect_to archived_clients_path, alert: exception
  end

  def archive
    if @client.current_family_id
      redirect_to @client, alert: "Can't delete client because the client is still attached with family"
    else
      # Not using deestroy to avoid callbacks
      @client.update_columns(deleted_at: Time.current, archived_by_id: current_user.id)
      redirect_to clients_url, notice: t('.successfully_archived')
    end
  rescue ActiveRecord::Rollback => exception
    redirect_to @client, alert: exception
  end

  def quantitative_case
    if params[:id].blank?
      render json: QuantitativeCase.all, root: :data
    else
      render json: QuantitativeCase.quantitative_cases_by_type(params[:id]), root: :data
    end
  end

  def version
    page = params[:per_page] || 20
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id]).decorate
    @versions = @client.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  def load_client_table_summary
    $param_rules = params

    if searched_client_ids.present?
      @results = @clients_by_user = Client.where(id: searched_client_ids.split(','))
    else
      choose_grid
      $param_rules = params
      basic_rules = JSON.parse(params[:basic_rules] || '{}')
      _clients, query = AdvancedSearches::ClientAdvancedSearch.new(basic_rules, Client.accessible_by(current_ability)).filter
      @results = @clients_by_user = @client_grid.scope { |scope| scope.where(query).accessible_by(current_ability) }.assets
    end

    render json: {
      client_table_content: render_to_string(partial: 'clients/client_table_summary_content')
    }
  end

  def load_statistics_data
    clients = if searched_client_ids.present?
                Client.where(id: searched_client_ids.split(','))
              else
                choose_grid
                $param_rules = params
                basic_rules = JSON.parse(params[:basic_rules] || '{}')
                _clients, query = AdvancedSearches::ClientAdvancedSearch.new(basic_rules, Client.accessible_by(current_ability)).filter
                clients = @client_grid.scope { |scope| scope.where(query).accessible_by(current_ability) }.assets
              end

    render json: {
      csi_statistics: CsiStatistic.new(clients).assessment_domain_score,
      enrollments_statistics: ActiveEnrollmentStatistic.new(clients).statistic_data
    }
  end

  private

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:id]).decorate
  end

  def assign_client_attributes
    current_org = Organization.current
    Organization.switch_to 'shared'
    client_record = SharedClient.find_by(archived_slug: @client.archived_slug)
    if client_record.present?
      @client.given_name = client_record.given_name
      @client.family_name = client_record.family_name
      @client.local_given_name = client_record.local_given_name
      @client.local_family_name = client_record.local_family_name
      @client.gender = client_record.gender
      @client.date_of_birth = client_record.date_of_birth
      @client.telephone_number = client_record.telephone_number
      @client.live_with = client_record.live_with
      @client.birth_province_id = client_record.birth_province_id
    end
    Organization.switch_to current_org.short_name
  end

  def client_params
    remove_blank_exit_reasons
    client_params = params.require(:client)
      .permit(
        :slug, :archived_slug, :code, :name_of_referee, :main_school_contact, :rated_for_id_poor, :what3words, :status, :country_origin,
        :kid_id, :assessment_id, :given_name, :family_name, :local_given_name, :local_family_name, :gender, :date_of_birth,
        :birth_province_id, :initial_referral_date, :referral_source_id, :telephone_number,
        :referral_phone, :received_by_id, :followed_up_by_id, :global_id, :shared_service_enabled,
        :follow_up_date, :school_grade, :school_name, :current_address, :locality, :phone_owner,
        :house_number, :street_number, :suburb, :description_house_landmark, :directions, :street_line1, :street_line2, :plot, :road, :postal_code, :district_id, :subdistrict_id,
        :has_been_in_orphanage, :has_been_in_government_care, :external_id, :external_id_display, :mosvy_number,
        :relevant_referral_information, :province_id, :current_family_id, :reason_for_referral,
        :state_id, :township_id, :rejected_note, :live_with, :profile, :remove_profile,
        :gov_city, :gov_commune, :gov_district, :gov_date, :gov_village_code, :gov_client_code,
        :gov_interview_village, :gov_interview_commune, :gov_interview_district, :gov_interview_city,
        :gov_caseworker_name, :gov_caseworker_phone, :gov_carer_name, :gov_carer_relationship, :gov_carer_home,
        :gov_carer_street, :gov_carer_village, :gov_carer_commune, :gov_carer_district, :gov_carer_city, :gov_carer_phone,
        :gov_information_source, :gov_referral_reason, :gov_guardian_comment, :gov_caseworker_comment, :commune_id, :village_id, :referral_source_category_id, :referee_id, :carer_id,
        :presented_id, :legacy_brcs_id, :id_number, :whatsapp, :other_phone_number, :brsc_branch, :current_island, :current_street,
        :current_po_box, :current_settlement, :current_resident_own_or_rent, :current_household_type,
        :island2, :street2, :po_box2, :settlement2, :resident_own_or_rent2, :household_type2,
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

    field_settings.each do |field_setting|
      next if field_setting.group != 'client' || field_setting.required? || field_setting.visible?

      client_params.except!(field_setting.name.to_sym)
    end

    client_params
  end

  def remove_blank_exit_reasons
    return if params[:client][:exit_reasons].blank?
    params[:client][:exit_reasons].reject!(&:blank?)
  end

  def set_association
    @agencies = Agency.cached_order_name
    @donors = Donor.cached_order_name
    @users = User.without_deleted_users.non_strategic_overviewers.order(:first_name, :last_name)
    @interviewees = Interviewee.cached_order_created_at
    @client_types = ClientType.cached_order_created_at
    @needs = Need.cached_order_created_at
    @problems = Problem.cached_order_created_at

    subordinate_users = User.where('manager_ids && ARRAY[:user_id] OR id = :user_id', { user_id: current_user.id }).map(&:id)
    if current_user.admin? || current_user.hotline_officer?
      @families = Family.order(:name)
    else
      @families = Family.accessible_by(current_ability).order(:name)
    end

    find_referral_by_params if params[:referral_id]

    @carer = @client && @client.carer.present? ? @client.carer : Carer.new
    @referee = @client && @client.referee.present? ? @client.referee : Referee.new(name: @referral&.name_of_referee, phone: @referral&.referral_phone, email: @referral&.referee_email)
    @referee.anonymous = true if current_organization.short_name == 'brc' && @referee.new_record?
    @referee_relationships = Client::RELATIONSHIP_TO_CALLER.map { |relationship| { label: relationship, value: relationship.downcase } }
    @client_relationships = Carer::CLIENT_RELATIONSHIPS.map { |relationship| { label: relationship, value: relationship.downcase } }
    @caller_relationships = Client::RELATIONSHIP_TO_CALLER.map { |relationship| { label: relationship, value: relationship.downcase } }
    @address_types = Client::ADDRESS_TYPES.map { |type| { label: type, value: type.downcase } }
    @phone_owners = Client::PHONE_OWNERS.map { |owner| { label: owner, value: owner.downcase } }
    @referral_source = @client && @client.referral_source.present? ? ReferralSource.where(id: @client.referral_source_id).map { |r| [r&.name, r.id] } : []
    @referral_source_category = referral_source_name(ReferralSource.parent_categories, @client) if @client && @client.persisted?
    country_address_fields if @client
  end

  def country_address_fields
    selected_country = Setting.cache_first.country_name || params[:country]
    current_org = Organization.current.short_name
    Organization.switch_to 'shared'
    @birth_provinces = []
    Organization.pluck(:country).uniq.reject(&:blank?).map { |country| @birth_provinces << [country.titleize, Province.country_is(country).map { |p| [p.name, p.id] }] }
    Organization.switch_to current_org

    if selected_country&.downcase == 'thailand'
      @current_provinces = Province.order(:name).where.not('name ILIKE ?', '%/%')
      @districts = @client.province.present? ? @client.province.cached_districts : []
      @subdistricts = @client.district.present? ? @client.district.cached_subdistricts : []

      @referee_districts = @client.referee&.province.present? ? @client.referee.province.cached_districts : []
      @referee_subdistricts = @client.referee&.district.present? ? @client.referee.district.cached_subdistricts : []

      @carer_districts = @client.carer&.province.present? ? @client.carer.province.cached_districts : []
      @carer_subdistricts = @client.carer&.district.present? ? @client.carer.district.cached_subdistricts : []
    elsif selected_country&.downcase == 'myanmar'
      @states = State.order(:name)
      @townships = @client.state.present? ? @client.state.townships.order(:name) : []

      @referee_townships = @client.referee&.state.present? ? @client.referee.state.townships.order(:name) : []
      @carer_townships = @client.carer&.state.present? ? @client.carer.state.townships.order(:name) : []
    else
      @current_provinces = Province.cached_order_name
      @districts = @client.province.present? ? @client.province.cached_districts : []
      @communes = @client.district.present? ? @client.district.cached_communes : []
      @villages = @client.commune.present? ? @client.commune.cached_villages : []

      @referee_districts = @client.referee&.province.present? ? @client.referee.province.cached_districts : []
      @referee_communes = @client.referee&.district.present? ? @client.referee.district.cached_communes : []
      @referee_villages = @client.referee&.commune.present? ? @client.referee.commune.cached_villages : []

      @carer_districts = @client.carer&.province.present? ? @client.carer.province.cached_districts : []
      @carer_communes = @client.carer&.district.present? ? @client.carer.district.cached_communes : []
      @carer_villages = @client.carer&.commune.present? ? @client.carer.commune.cached_villages : []
    end
  end

  def initial_visit_client
    referrer = Rails.application.routes.recognize_path(request.referrer.gsub(/[a-z]{3,}\-/, '').gsub('/?', '?')) if request.referrer
    return unless referrer.present?

    white_list_referrers = %w[clients]
    controller_name = referrer[:controller]

    VisitClient.initial_visit_client(current_user) if white_list_referrers.include?(controller_name)
  end

  def quantitative_type_editable
    @quantitative_type_editable_ids = current_user.quantitative_type_permissions.editable.pluck(:quantitative_type_id)
  end

  def quantitative_type_readable
    @quantitative_type_readable_ids = current_user.quantitative_type_permissions.readable.pluck(:quantitative_type_id)
  end

  def find_referral_by_params
    @referral ||= Referral.find_by(id: params[:referral_id])
    raise ActiveRecord::RecordNotFound if @referral.nil?
  end

  def find_referral_source_by_referral
    referral_source_org = Organization.find_by(short_name: @referral.referred_from)&.full_name
    if referral_source_org
      ReferralSource.child_referrals.find_by(name: "#{referral_source_org} - OSCaR Referral")&.id
    else
      ReferralSource.child_referrals.find_by(name: @referral.referred_from)&.id
    end
  end

  def fetch_referral_attibutes(attributes, referral_source_id, referral_attr = {})
    attributes.merge!({
      initial_referral_date: referral_attr['date_of_referral'],
      referral_phone: referral_attr['referral_phone'],
      relevant_referral_information: referral_attr['referral_reason'],
      name_of_referee: referral_attr['name_of_referee'],
      referral_source_id: referral_source_id
    })
  end

  def validate_referral
    return if params[:referral_id].blank?

    find_referral_by_params
    redirect_to root_path, alert: t('clients.edit.referral_has_already_been_saved') if @referral.saved?
  end

  def exited_clients(user_ids)
    client_ids = CaseWorkerClient.where(id: PaperTrail::Version.where(item_type: 'CaseWorkerClient', event: 'create').joins(:version_associations).where(version_associations: { foreign_key_name: 'user_id', foreign_key_id: user_ids }).distinct.map(&:item_id)).pluck(:client_id).uniq
    Client.where(id: client_ids, status: 'Exited').ids
  end

  def assign_active_client_prams
    return if params[:active_client].blank?

    params[:client_advanced_search] = {
      action_report_builder: '#builder',
      basic_rules: "{\"condition\":\"AND\",\"rules\":[{\"id\":\"status\",\"field\":\"Status\",\"type\":\"string\",\"input\":\"select\",\"operator\":\"equal\",\"value\":\"Active\",\"data\":{\"values\":[{\"Accepted\":\"Accepted\"},{\"Active\":\"Active\"},{\"Exited\":\"Exited\"},{\"Referred\":\"Referred\"}],\"isAssociation\":false}}],\"valid\":true}"
    }
  end
end
