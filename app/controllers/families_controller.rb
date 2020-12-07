class FamiliesController < AdminController
  load_and_authorize_resource
  include FamilyAdvancedSearchesConcern

  before_action :find_params_advanced_search, :get_custom_form, only: [:index]
  before_action :get_custom_form_fields, :family_builder_fields, only: [:index]
  before_action :basic_params, if: :has_params?, only: [:index]
  before_action :build_advanced_search, only: [:index]
  before_action :find_association, except: [:index, :destroy, :version]
  before_action :find_family, only: [:show, :edit, :update, :destroy]
  before_action :load_quantative_types, only: [:new, :edit, :create, :update]

  def index
    @default_columns = Setting.first.try(:family_default_columns)
    @family_grid = FamilyGrid.new(params.fetch(:family_grid, {}).merge!(dynamic_columns: @custom_form_fields))
    @family_grid = @family_grid.scope { |scope| scope.accessible_by(current_ability) }
    @family_columns ||= FamilyColumnsVisibility.new(@family_grid, params.merge(column_form_builder: @custom_form_fields))
    @family_columns.visible_columns
    if has_params?
      advanced_search
    else
      respond_to do |f|
        f.html do
          @results = @family_grid.assets.size
          @family_grid.scope { |scope| scope.accessible_by(current_ability).page(params[:page]).per(20) }
        end
        f.xls do
          form_builder_report
          send_data @family_grid.to_xls, filename: "family_report-#{Time.now}.xls"
        end
      end
    end
  end

  def new
    @family = Family.new
    @family.family_members.new
    @selected_children = params[:children]
  end

  def create
    @family = Family.new(family_params)
    @family.user_id = current_user.id

    if @family.save!
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
  end

  def update
    if @family.update_attributes(family_params)
      redirect_to @family, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @family.current_clients.blank? && (@family.cases.present? && @family.cases.delete_all || true) && @family.destroy
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
    params.require(:family).permit(
      :name, :code,
      :dependable_income, :family_type, :status, :contract_date,
      :address, :province_id, :district_id, :house, :street,
      :commune_id, :village_id,
      :followed_up_by_id, :follow_up_date, :name_en, :phone_number, :id_poor, :referral_source_id,
      :referee_phone_number, :relevant_information,
      :received_by_id, :initial_referral_date, :referral_source_category_id,
      donor_ids: [], community_ids: [],
      case_worker_ids: [],
      custom_field_ids: [],
      family_members_attributes: [
        :monthly_income, :client_id,
        :id, :gender, :note, :adult_name, :date_of_birth,
        :occupation, :relation, :guardian, :_destroy
      ]
    )
  end

  def find_association
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
end
