class CommunitiesController < AdminController
  load_and_authorize_resource
  include CommunityAdvancedSearchConcern
  include CommunityGridOptions

  before_action :find_params_advanced_search, :list_custom_form, only: [:index]
  before_action :custom_form_fields, :community_builder_fields, only: [:index]
  before_action :quantitative_fields, only: [:index]
  before_action :basic_params, if: :has_params?, only: [:index]
  before_action :choose_grid, :build_advanced_search, only: [:index]
  before_action :find_association, except: [:index, :destroy, :version]
  before_action :find_community, only: [:show, :edit, :update, :destroy]
  before_action :load_quantative_types, only: [:new, :edit, :create, :update]

  def welcome
    choose_grid
  end

  def index
    if has_params?
      advanced_search
    else
      columns_visibility
      respond_to do |f|
        f.html do
          if params[:community_grid].present?
            @results = @community_grid.assets.size
            @community_grid.scope { |scope| scope.accessible_by(current_ability).page(params[:page]).per(20) }
          end
        end
        f.xls do
          form_builder_report
          send_data @community_grid.to_xls, filename: "community_report-#{Time.now}.xls"
        end
      end
    end
  end

  def new
    @community = Community.new
    @community.community_members.new
  end

  def create
    @community = Community.new(community_params)
    @community.user_id = current_user.id

    if @community.save
      redirect_to @community, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def show
    custom_field_ids = @community.custom_field_properties.pluck(:custom_field_id)
    @free_community_forms = CustomField.community_forms.not_used_forms(custom_field_ids).order_by_form_title
    @group_community_custom_fields = @community.custom_field_properties.group_by(&:custom_field_id)
  end

  def edit
  end

  def update
    if @community.update_attributes(community_params)
      redirect_to @community, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @community.destroy
      redirect_to communities_path, notice: t('.successfully_deleted')
    else
      redirect_to community_path(@community), alert: t('.alert')
    end
  end

  def version
    page = params[:per_page] || 20
    @community = Community.find(params[:family_id])
    @versions = @community.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def load_quantative_types
    @quantitative_types = QuantitativeType.where('visible_on LIKE ?', '%community%')
  end

  def community_params
    params.require(:community).permit(
      :received_by_id,
      :initial_referral_date,
      :referral_source_category_id,
      :referral_source_id,
      :name,
      :name_en,
      :formed_date,
      :province_id,
      :city_id,
      :district_id,
      :subdistrict_id,
      :commune_id,
      :village_id,
      :representative_name,
      :gender,
      :role,
      :phone_number,
      :relevant_information,
      donor_ids: [],
      case_worker_ids: [],
      quantitative_case_ids: [],
      documents: [],
      community_quantitative_free_text_cases_attributes: [
        :id, :content, :quantitative_type_id
      ],
      community_members_attributes: [
        :family_id,
        :id, :gender, :name, :role,
        :adule_male_count, :adule_female_count, :kid_male_count, :kid_female_count, :_destroy
      ]
    )
  end

  def find_association
    @provinces = Province.cached_order_name
    if current_organization.country == 'indonesia'
      @cities = @community&.province_id.present? ? @community.province.cached_cities : []
      @districts = @community&.city_id.present? ? @community.city.cached_districts : []
      @subdistricts = @community&.subdistrict_id.present? ? @community.district.cached_subdistricts : []
    else
      @districts = @community&.province_id.present? ? @community.province.cached_districts : []
      @communes = @community&.district_id.present? ? @community.district.cached_communes : []
      @villages = @community&.commune_id.present? ? @community.commune.cached_villages : []
    end
  end

  def find_community
    @community = Community.find(params[:id])
  end
end
