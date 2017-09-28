class FamiliesController < AdminController
  load_and_authorize_resource

  before_action :find_association, except: [:index, :destroy, :version]
  before_action :find_family, only: [:show, :edit, :update, :destroy]

  def index
    @family_grid = FamilyGrid.new(params[:family_grid])
    respond_to do |f|
      f.html do
        @results = @family_grid.assets.size
        @family_grid.scope { |scope| scope.page(params[:page]).per(20) }
      end
      f.xls do
        send_data @family_grid.to_xls, filename: "family_report-#{Time.now}.xls"
      end
    end
  end

  def new
    @family = Family.new
  end

  def create
    @family = Family.new(family_params)
    if @family.save
      redirect_to @family, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def show
    custom_field_ids            = @family.custom_field_properties.pluck(:custom_field_id)
    @free_family_forms          = CustomField.family_forms.not_used_forms(custom_field_ids).order_by_form_title
    @group_family_custom_fields = @family.custom_field_properties.group_by(&:custom_field_id)
    @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(family_id: @family.id))
    @results = @client_grid.assets.uniq.size
    @client_grid.scope { |scope| scope.page(params[:page]).per(5).uniq }
  end

  def edit
  end

  def update
    # if client_associations.any? && @family.is_case?
    #   redirect_to request.referrer, alert: t('.not_allowed_to_detach_clients')
    # else
    if @family.update_attributes(family_params)
      redirect_to @family, notice: t('.successfully_updated')
    else
      render :edit
    end
    # end
  end

  def destroy
    if @family.cases_count.zero?
      @family.destroy
      redirect_to families_url, notice: t('.successfully_deleted')
    else
      redirect_to families_url, alert: t('.alert')
    end
  end

  def version
    page = params[:per_page] || 20
    @family   = Family.find(params[:family_id])
    @versions = @family.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def family_params
    params['family']['children'].delete_if(&:empty?)
    params.require(:family).permit(
                            :name, :code, :case_history, :caregiver_information,
                            :significant_family_member_count, :household_income,
                            :dependable_income, :female_children_count,
                            :male_children_count, :female_adult_count,
                            :male_adult_count, :family_type, :contract_date,
                            :address, :province_id,
                            custom_field_ids: [],
                            # client_ids: [],
                            children: []
                            )
  end

  def find_association
    # @clients  = Client.accessible_by(current_ability).joins('LEFT OUTER JOIN cases ON cases.client_id = clients.id').where('cases.family_id = ? OR (clients.status = ? AND clients.state = ?)', @family.id, 'Referred', 'accepted').order(:given_name, :family_name).uniq
    @clients  = Client.accessible_by(current_ability).order(:given_name, :family_name)
    @province = Province.order(:name)
  end

  def find_family
    @family = Family.find(params[:id])
  end

  def client_associations
    @family.client_ids.uniq - params[:family][:client_ids].map{|a| a.to_i }
  end
end
