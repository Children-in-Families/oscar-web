class FamiliesController < AdminController
  load_and_authorize_resource
  include FamilyAdvancedSearchesConcern

  before_action :assign_active_family_prams, :format_search_params, only: [:index]
  before_action :find_params_advanced_search, :get_custom_form, :get_program_streams, only: [:index]
  before_action :get_custom_form_fields, :get_quantitative_fields, :family_builder_fields, only: [:index]
  before_action :custom_form_fields, :program_stream_fields, only: [:index]
  before_action :basic_params, if: :has_params?, only: [:index]
  before_action :build_advanced_search, only: [:index]
  before_action :find_association, except: [:index, :destroy, :version]
  before_action :find_family, only: [:show, :edit, :update, :destroy]
  before_action :find_case_histories, only: :show
  before_action :quantitative_type_readable
  before_action :load_quantative_types, only: [:new, :edit, :create, :update]

  def index
    @default_columns = Setting.first.try(:family_default_columns)
    @family_grid = FamilyGrid.new(params.fetch(:family_grid, {}).merge!(dynamic_columns: column_form_builder))
    @family_grid = @family_grid.scope { |scope| scope.accessible_by(current_ability) }
    @family_columns ||= FamilyColumnsVisibility.new(@family_grid, params.merge(column_form_builder: column_form_builder))
    @family_columns.visible_columns
    if has_params? || params[:advanced_search_id].present? || params[:family_advanced_search].present?
      advanced_search
    else
      respond_to do |f|
        f.html do
          @results = @family_grid.assets
          @family_grid.scope { |scope| scope.accessible_by(current_ability).page(params[:page]).per(20) }
        end
        f.xls do
          export_family_reports
          send_data @family_grid.to_xls, filename: "family_report-#{Time.now}.xls"
        end
      end
    end
  end

  def new
    if params[:referral_id].present?
      current_org = Organization.current
      find_referral_by_params
      Organization.switch_to @family_referral.referred_from
      attributes = fetch_family_attibutes(@family_referral.slug, current_org)
    else
      @family = Family.new
      @family.build_community_member
      @selected_children = params[:children]

      if params[:client].present?
        @family.family_members.new(client_id: params[:client])
      else
        @family.family_members.new
      end
    end
  end

  def create
    @family = Family.new(family_params)
    @family.user_id = current_user.id
    @family.case_management_record = !current_setting.hide_family_case_management_tool?

    if @family.save
      redirect_to @family, notice: t('.successfully_created')
    else
      @selected_children = family_params[:children]
      render :new
    end
  end

  def show
    custom_field_ids            = @family.custom_field_properties.pluck(:custom_field_id)
    @free_family_forms          = CustomField.family_forms.not_used_forms(custom_field_ids).order_by_form_title
    @group_family_custom_fields = @family.custom_field_properties.group_by(&:custom_field_id)
    client_ids = @family.current_clients.ids
    if client_ids.present?
      @client_grid = ClientGrid.new(params[:client_grid])
      @results = @client_grid.scope.where(current_family_id: @family.id).uniq.size
      @client_grid.scope { |scope| scope.includes(:enter_ngos, :exit_ngos).where(id: client_ids).page(params[:page]).per(10).uniq }
    end
  end

  def edit
    @family.build_community_member
  end

  def update
    @family.case_management_record = !current_setting.hide_family_case_management_tool?
    if @family.update_attributes(family_params)
      redirect_to @family, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @family.case_worker_families.with_deleted.each(&:destroy_fully!)
    if @family.current_clients.blank? && (@family.cases.present? && @family.cases.delete_all || true) && @family.destroy
      Task.with_deleted.where(family_id: @family.id).each(&:destroy_fully!)
      redirect_to families_url, notice: t('.successfully_deleted')
    else
      redirect_to family_path(@family), alert: t('.alert')
    end
  end

  def version
    page = params[:per_page] || 20
    @family   = Family.find(params[:family_id])
    @versions = @family.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def load_quantative_types
    @quantitative_types = QuantitativeType.where('visible_on LIKE ?', "%family%")
  end

  def family_params
    permitted_params = params.require(:family).permit(
      :name, :code,
      :dependable_income, :family_type, :status, :contract_date,
      :address, :province_id, :district_id, :house, :street,
      :commune_id, :village_id, :slug,
      :followed_up_by_id, :follow_up_date, :name_en, :phone_number, :id_poor, :referral_source_id,
      :referee_phone_number, :relevant_information,
      :received_by_id, :initial_referral_date, :referral_source_category_id,
      donor_ids: [], community_ids: [],
      case_worker_ids: [],
      custom_field_ids: [],
      quantitative_case_ids: [],
      documents: [],
      community_member_attributes: [:id, :community_id, :_destroy],
      family_members_attributes: [
        :monthly_income, :client_id,
        :id, :gender, :note, :adult_name, :date_of_birth,
        :occupation, :relation, :guardian, :_destroy
      ]
    )

    if permitted_params[:community_member_attributes].present?
      permitted_params[:community_member_attributes][:_destroy] = 1 if permitted_params.dig(:community_member_attributes, :community_id).blank?
    end

    permitted_params
  end

  def find_association
    @users     = User.deleted_user.non_strategic_overviewers.order(:first_name, :last_name)
    @provinces = Province.order(:name)
    @districts = @family.province.present? ? @family.province.districts.order(:name) : []
    @communes  = @family.district.present? ? @family.district.communes.order(:code) : []
    @villages  = @family.commune.present? ? @family.commune.villages.order(:code) : []
    if action_name.in?(['edit', 'update'])
      client_ids = Family.where.not(id: @family).pluck(:children).flatten.uniq - @family.children
    else
      client_ids = Family.where.not(id: @family).pluck(:children).flatten.uniq
    end

    client_ids = Client.where("current_family_id = ? OR id NOT IN (?) OR current_family_id IS NULL", @family.id, Client.joins(:families).ids).ids
    @clients  = Client.accessible_by(current_ability).where(id: client_ids).order(:given_name, :family_name)
  end

  def find_family
    @family = Family.find(params[:id])
  end

  def find_case_histories
    enter_ngos = @family.enter_ngos
    exit_ngos  = @family.exit_ngos
    cps_enrollments = @family.enrollments
    cps_leave_programs = LeaveProgram.joins(:enrollment).where("enrollments.programmable_id = ?", @family.id)
    @case_histories = (enter_ngos + exit_ngos + cps_enrollments + cps_leave_programs).sort { |current_record, next_record| -([current_record.created_at, current_record.new_date] <=> [next_record.created_at, next_record.new_date]) }
  end

  def find_referral_by_params
    @family_referral ||= FamilyReferral.find_by(id: params[:referral_id])
    raise ActiveRecord::RecordNotFound if @family_referral.nil?
  end

  def fetch_family_attibutes(family_slug, current_org)
    attributes = Family.find_by(slug: family_slug).try(:attributes)
    referee_phone_number = @family_referral.referral_phone

    if attributes.present?
      province_name = Province.find_by(id: attributes['province_id']).try(:name)
      district_code = District.find_by(id: attributes['district_id']).try(:code)
      village_code = Village.find_by(id: attributes['village_id']).try(:code)
      commune_code = Commune.find_by(id: attributes['commune_id']).try(:code)

      Organization.switch_to current_org.short_name
      province_id = Province.find_by(name: province_name).try(:id)
      district_id = District.find_by(code: district_code).try(:id)
      village_id = Village.find_by(code: village_code).try(:id)
      commune_id = Commune.find_by(code: commune_code).try(:id)

      attributes = attributes.slice('name', 'name_en', 'house', 'street', 'slug', 'initial_referral_date').merge!({province_id: province_id, district_id: district_id, commune_id: commune_id, village_id: village_id, referee_phone_number: referee_phone_number})
      @family.province = Province.find_by(id: province_id)
      @family.district = District.find_by(id: district_id)
      @family.commune = Commune.find_by(id: commune_id)
      @family.village = Village.find_by(id: village_id)

      @provinces = Province.order(:name)
      @districts = @family.province.present? ? @family.province.districts.order(:name) : []
      @communes  = @family.district.present? ? @family.district.communes.order(:code) : []
      @villages  = @family.commune.present? ? @family.commune.villages.order(:code) : []
    end
    @family = Family.new(attributes)
    @selected_children = params[:children]
  end

  def assign_active_family_prams
    return if params[:active_family].blank?

    params[:family_advanced_search] = {
      action_report_builder: '#builder',
      basic_rules: "{\"condition\":\"AND\",\"rules\":[{\"id\":\"status\",\"field\":\"Status\",\"type\":\"string\",\"input\":\"select\",\"operator\":\"equal\",\"value\":\"Active\",\"data\":{\"values\":[{\"Accepted\":\"Accepted\"},{\"Active\":\"Active\"},{\"Exited\":\"Exited\"},{\"Referred\":\"Referred\"}],\"isAssociation\":false}}],\"valid\":true}"
    }
  end

  def column_form_builder
    forms = []
    if @custom_form_fields.present?
      forms << @custom_form_fields
    end

    if @program_stream_fields.present?
      forms << @program_stream_fields
    end

    forms.flatten
  end

  def assign_active_family_prams
    return if params[:active_family].blank?

    params[:family_advanced_search] = {
      action_report_builder: '#builder',
      basic_rules: "{\"condition\":\"AND\",\"rules\":[{\"id\":\"status\",\"field\":\"Status\",\"type\":\"string\",\"input\":\"select\",\"operator\":\"equal\",\"value\":\"Active\",\"data\":{\"values\":[{\"Accepted\":\"Accepted\"},{\"Active\":\"Active\"},{\"Exited\":\"Exited\"},{\"Referred\":\"Referred\"}],\"isAssociation\":false}}],\"valid\":true}"
    }
  end

  def quantitative_type_readable
    @quantitative_type_readable_ids = current_user.quantitative_type_permissions.readable.pluck(:quantitative_type_id)
  end
end
