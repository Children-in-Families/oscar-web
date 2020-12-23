class CommunitiesController < AdminController
  # load_and_authorize_resource
  # include FamilyAdvancedSearchesConcern
  #
  # before_action :find_params_advanced_search, :get_custom_form, only: [:index]
  # before_action :get_custom_form_fields, :family_builder_fields, only: [:index]
  # before_action :basic_params, if: :has_params?, only: [:index]
  # before_action :build_advanced_search, only: [:index]
  before_action :find_association, except: [:index, :destroy, :version]
  # before_action :find_community, only: [:show, :edit, :update, :destroy]
  before_action :load_quantative_types, only: [:new, :edit, :create, :update]

  def index
    # @default_columns = Setting.first.try(:family_default_columns)
    # @community_grid = FamilyGrid.new(params.fetch(:family_grid, {}).merge!(dynamic_columns: @custom_form_fields))
    # @community_grid = @community_grid.scope { |scope| scope.accessible_by(current_ability) }
    # @community_columns ||= FamilyColumnsVisibility.new(@community_grid, params.merge(column_form_builder: @custom_form_fields))
    # @community_columns.visible_columns
    # if has_params?
    #   advanced_search
    # else
    #   respond_to do |f|
    #     f.html do
    #       @results = @community_grid.assets.size
    #       @community_grid.scope { |scope| scope.accessible_by(current_ability).page(params[:page]).per(20) }
    #     end
    #     f.xls do
    #       form_builder_report
    #       send_data @community_grid.to_xls, filename: "family_report-#{Time.now}.xls"
    #     end
    #   end
    # end
  end

  def new
    @community = Community.new
    @community.community_members.new
  end

  def create
    # @community = Family.new(family_params)
    # @community.user_id = current_user.id
    # @community.case_management_record = !current_setting.hide_family_case_management_tool?
    #
    # if @community.save
    #   redirect_to @community, notice: t('.successfully_created')
    # else
    #   @selected_children = family_params[:children]
    #   render :new
    # end
  end

  def show
    # custom_field_ids            = @community.custom_field_properties.pluck(:custom_field_id)
    # @free_family_forms          = CustomField.family_forms.not_used_forms(custom_field_ids).order_by_form_title
    # @group_family_custom_fields = @community.custom_field_properties.group_by(&:custom_field_id)
    # client_ids = @community.current_clients.ids
    # if client_ids.present?
    #   @client_grid = ClientGrid.new(params[:client_grid])
    #   @results = @client_grid.scope.where(current_family_id: @community.id).uniq.size
    #   @client_grid.scope { |scope| scope.includes(:enter_ngos, :exit_ngos).where(id: client_ids).page(params[:page]).per(10).uniq }
    # end
  end

  def edit
  end

  def update
    # @community.case_management_record = !current_setting.hide_family_case_management_tool?
    # if @community.update_attributes(family_params)
    #   redirect_to @community, notice: t('.successfully_updated')
    # else
    #   render :edit
    # end
  end

  def destroy
    # if @community.current_clients.blank? && (@community.cases.present? && @community.cases.delete_all || true) && @community.destroy
    #   redirect_to families_url, notice: t('.successfully_deleted')
    # else
    #   redirect_to family_path(@community), alert: t('.alert')
    # end
  end

  # def version
  #   page = params[:per_page] || 20
  #   @community   = Family.find(params[:family_id])
  #   @versions = @community.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  # end

  private

  def load_quantative_types
    @quantitative_types = QuantitativeType.where('visible_on LIKE ?', "%community%")
  end

  def community_params
    params.require(:community).permit(
      :name,
      :province_id, :district_id, :house, :street,
      :commune_id, :village_id,
      :followed_up_by_id, :follow_up_date, :name_en, :phone_number, :referral_source_id,
      :relevant_information,
      :received_by_id, :initial_referral_date, :referral_source_category_id,
      donor_ids: [],
      case_worker_ids: [],
      custom_field_ids: [],
      quantitative_case_ids: [],
      documents: [],
      community_members_attributes: [
        :monthly_income, :family_id,
        :id, :gender, :adult_name, :date_of_birth,
        :occupation, :relation, :guardian, :_destroy
      ]
    )
  end

  def find_association
    @provinces = Province.order(:name)
    @districts = @community&.province.present? ? @community.province.districts.order(:name) : []
    @communes  = @community&.district.present? ? @community.district.communes.order(:code) : []
    @villages  = @community&.commune.present? ? @community.commune.villages.order(:code) : []
  end

  def find_community
    @community = Community.find(params[:id])
  end
end
