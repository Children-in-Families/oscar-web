class ClientsController < AdminController
  load_and_authorize_resource find_by: :slug, except: :quantitative_case

  include ClientAdvancedSearchesConcern
  include ClientGridOptions

  before_action :get_quantitative_fields, only: [:index]
  before_action :find_params_advanced_search, :get_custom_form, :get_program_streams, only: [:index]
  before_action :get_custom_form_fields, :program_stream_fields, :custom_form_fields, :client_builder_fields, only: [:index]
  before_action :basic_params, if: :has_params?, only: [:index]
  before_action :build_advanced_search, only: [:index]
  before_action :fetch_advanced_search_queries, only: [:index]

  before_action :find_client, only: [:show, :edit, :update, :destroy]
  before_action :assign_client_attributes, only: [:show, :edit]
  before_action :set_association, except: [:index, :destroy, :version]
  before_action :choose_grid, only: :index
  before_action :quantitative_type_editable, only: [:edit, :update, :new, :create]
  before_action :quantitative_type_readable
  before_action :validate_referral, only: [:new, :edit]

  def index
    @client_default_columns = Setting.first.try(:client_default_columns)
    if has_params?
      advanced_search
    else
      columns_visibility
      respond_to do |f|
        f.html do
          next unless params['commit'].present?
          client_grid             = @client_grid.scope { |scope| scope.accessible_by(current_ability) }
          @results                = client_grid.assets.size
          $client_data            = client_grid.assets
          @clients                = client_grid.assets
          @client_grid.scope { |scope| scope.accessible_by(current_ability).page(params[:page]).per(20) }
        end
        f.xls do
          next unless params['commit'].present?
          @client_grid.scope { |scope| scope.accessible_by(current_ability) }
          export_client_reports
          send_data @client_grid.to_xls, filename: "client_report-#{Time.now}.xls"
          # current_time = Time.now
          # if params[:type] == 'basic_info'
          #   export_client_reports
          #   send_data @client_grid.to_xls, filename: "client_report-#{current_time}.xls"
          # elsif params[:type] == 'csi_assessment'
          #   send_data @client_grid.to_spreadsheet('default'), filename: "client_assessment_domain_report-#{current_time}.xls"
          # elsif params[:type] == 'custom_assessment'
          #   send_data @client_grid.to_spreadsheet('custom'), filename: "client_assessment_domain_report-#{current_time}.xls"
          # end
        end
      end
    end
  end

  def show
    respond_to do |format|
      format.html do
        custom_field_ids            = @client.custom_field_properties.pluck(:custom_field_id)
        if current_user.admin? || current_user.strategic_overviewer?
          available_editable_forms  = CustomField.all
          readable_forms            = @client.custom_field_properties
        else
          available_editable_forms  = CustomField.where(id: current_user.custom_field_permissions.where(editable: true).pluck(:custom_field_id))
          readable_forms            = @client.custom_field_properties.where(custom_field_id: current_user.custom_field_permissions.where(readable: true).pluck(:custom_field_id))
        end

        @free_client_forms          = available_editable_forms.client_forms.not_used_forms(custom_field_ids).order_by_form_title
        @group_client_custom_fields = readable_forms.sort_by{ |c| c.custom_field.form_title }.group_by(&:custom_field_id)
        initial_visit_client
        # @enter_ngos = @client.enter_ngos.order(:accepted_date)
        # @exit_ngos  = @client.exit_ngos.order(:exit_date)
        enter_ngos = @client.enter_ngos
        exit_ngos  = @client.exit_ngos
        cps_enrollments = @client.client_enrollments
        cps_leave_programs = LeaveProgram.joins(:client_enrollment).where("client_enrollments.client_id = ?", @client.id)
        referrals = @client.referrals
        @case_histories = (enter_ngos + exit_ngos + cps_enrollments + cps_leave_programs + referrals).sort { |current_record, next_record| -([current_record.new_date, current_record.created_at] <=> [next_record.new_date, next_record.created_at]) }
        # @quantitative_type_readable_ids = current_user.quantitative_type_permissions.readable.pluck(:quantitative_type_id)
      end
      format.pdf do
        form        = params[:form]
        form_title  = t(".government_form_#{form}")
        # form_title  = t(".government_form_one")
        client_name = @client.en_and_local_name
        pdf_name    = "#{client_name} - #{form_title}"
        render  pdf:      pdf_name,
                template: 'clients/show.pdf.haml',
                page_size: 'A4',
                layout:   'pdf_design.html.haml',
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

      Organization.switch_to 'shared'
      attributes = SharedClient.find_by(slug: @referral.slug).attributes
      attributes = fetch_referral_attibutes(attributes, referral_source_id)

      Organization.switch_to current_org.short_name
      @client = Client.new(attributes)
    else
      @client = Client.new
    end
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
  end

  def create
    @client = Client.new(client_params)
    if @client.save
      redirect_to @client, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def update
    if @client.update_attributes(client_params)
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

  def destroy
    @client.reload.destroy

    redirect_to clients_url, notice: t('.successfully_deleted')
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
    @client   = Client.accessible_by(current_ability).friendly.find(params[:client_id]).decorate
    @versions = @client.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def find_client
    @client = Client.includes(custom_field_properties: [:custom_field], client_enrollments: [:program_stream]).accessible_by(current_ability).friendly.find(params[:id]).decorate
  end

  def assign_client_attributes
    current_org = Organization.current
    Organization.switch_to 'shared'
    client_record = SharedClient.find_by(slug: @client.slug)
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
    params.require(:client)
          .permit(
            :slug, :code, :name_of_referee, :main_school_contact, :rated_for_id_poor, :what3words, :status, :country_origin,
            :kid_id, :assessment_id, :given_name, :family_name, :local_given_name, :local_family_name, :gender, :date_of_birth,
            :birth_province_id, :initial_referral_date, :referral_source_id, :telephone_number,
            :referral_phone, :received_by_id, :followed_up_by_id,
            :follow_up_date, :school_grade, :school_name, :current_address,
            :house_number, :street_number, :suburb, :description_house_landmark, :directions, :street_line1, :street_line2, :plot, :road, :postal_code, :district_id, :subdistrict_id,
            :has_been_in_orphanage, :has_been_in_government_care,
            :relevant_referral_information, :province_id,
            :state_id, :township_id, :rejected_note, :live_with, :profile, :remove_profile,
            :gov_city, :gov_commune, :gov_district, :gov_date, :gov_village_code, :gov_client_code,
            :gov_interview_village, :gov_interview_commune, :gov_interview_district, :gov_interview_city,
            :gov_caseworker_name, :gov_caseworker_phone, :gov_carer_name, :gov_carer_relationship, :gov_carer_home,
            :gov_carer_street, :gov_carer_village, :gov_carer_commune, :gov_carer_district, :gov_carer_city, :gov_carer_phone,
            :gov_information_source, :gov_referral_reason, :gov_guardian_comment, :gov_caseworker_comment, :commune_id, :village_id,
            interviewee_ids: [],
            client_type_ids: [],
            user_ids: [],
            agency_ids: [],
            donor_ids: [],
            quantitative_case_ids: [],
            custom_field_ids: [],
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
    @referral_source = ReferralSource.order(:name)
    @users           = User.non_strategic_overviewers.order(:first_name, :last_name)
    @interviewees    = Interviewee.order(:created_at)
    @client_types    = ClientType.order(:created_at)
    @needs           = Need.order(:created_at)
    @problems        = Problem.order(:created_at)

    country_address_fields
  end

  def country_address_fields
    selected_country = Setting.first.try(:country_name) || params[:country]
    current_org = Organization.current.short_name
    Organization.switch_to 'shared'
    @birth_provinces = []
    ['Cambodia', 'Thailand', 'Lesotho', 'Myanmar'].map{ |country| @birth_provinces << [country, Province.country_is(country.downcase).map{|p| [p.name, p.id] }] }
    Organization.switch_to current_org
    @current_provinces        = Province.order(:name)
    @states                   = State.order(:name)
    @townships                = @client.state.present? ? @client.state.townships.order(:name) : []
    @districts                = @client.province.present? ? @client.province.districts.order(:name) : []
    @subdistricts             = @client.district.present? ? @client.district.subdistricts.order(:name) : []
    @communes                 = @client.district.present? ? @client.district.communes.order(:code) : []
    @villages                 = @client.commune.present? ? @client.commune.villages.order(:code) : []
  end

  def initial_visit_client
    referrer = Rails.application.routes.recognize_path(request.referrer)
    return unless referrer.present?
    white_list_referrers = %w(clients)
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
    @referral = Referral.find_by(id: params[:referral_id])
    raise ActiveRecord::RecordNotFound if @referral.nil?
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

  def validate_referral
    return if params[:referral_id].blank?
    find_referral_by_params
    redirect_to root_path, alert: t('.referral_has_already_been_saved') if @referral.saved?
  end
end
