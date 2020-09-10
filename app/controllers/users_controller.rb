class UsersController < AdminController
  load_and_authorize_resource

  before_action :find_user, only: [:show, :edit, :update, :destroy]
  before_action :find_association, except: [:index, :destroy, :version]

  def index
    @user_grid = UserGrid.new(params[:user_grid])
    respond_to do |f|
      f.html do
        @results = @user_grid.scope { |scope| scope.deleted_user.accessible_by(current_ability) }.assets.size
        @user_grid.scope { |scope| scope.deleted_user.accessible_by(current_ability).page(params[:page]).per(20) }
      end
      f.xls do
        @user_grid.scope { |scope| scope.deleted_user.accessible_by(current_ability) }
        send_data @user_grid.to_xls, filename: "user_report-#{Time.now}.xls"
      end
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params.merge({client_ids: []}))

    if @user.save
      @user.update_attributes(user_params) unless @user.strategic_overviewer?
      redirect_to @user, notice: t('.successfully_created')
    else
      @client_ids = user_params[:client_ids]
      render :new
    end
  end

  def show
    @user.populate_custom_fields unless @user.custom_field_permissions.any? || @user.admin? || @user.strategic_overviewer? || @user.case_worker?
    @user.populate_program_streams unless @user.admin? || @user.strategic_overviewer?
    @user.build_permission unless @user.permission.present? || @user.admin? || @user.strategic_overviewer?
    @user.populate_quantitative_types unless @user.quantitative_type_permissions.present? || @user.admin? || @user.strategic_overviewer?

    custom_field_ids          = @user.custom_field_properties.pluck(:custom_field_id)
    @free_user_forms          = CustomField.user_forms.not_used_forms(custom_field_ids).order_by_form_title
    @group_user_custom_fields = @user.custom_field_properties.group_by(&:custom_field_id)

    @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(current_user: @user))
    @results     = @client_grid.scope { |scope| scope.of_case_worker(@user.id) }.assets.size

    @client_grid.scope do |scope|
      scope.of_case_worker(@user.id).page(params[:page]).per(10)
    end
  end

  def edit
    @client_ids = @user.clients.ids
  end

  def update
    if @user.update_attributes(user_params)
      redirect_to @user, notice: t('.successfully_updated')
    else
      @client_ids = user_params[:client_ids]
      render :edit
    end
  end

  def destroy
    if @user.no_any_associated_objects?
      @user.update(disable: true, deleted_at: Time.zone.now)
      redirect_to users_url, notice: t('.successfully_deleted')
    else
      redirect_to users_url, alert: t('.alert')
    end
  end

  def version
    page = params[:per_page] || 20
    @user     = User.find(params[:user_id])
    @versions = @user.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  def disable
    @user = User.find(params[:user_id])
    user_disable_status = @user.disable
    @user.disable = !@user.disable
    @user.save(validate: false)
    if user_disable_status == false
      @user.update_attributes(deactivated_at: DateTime.now.in_time_zone(Time.zone))
    elsif user_disable_status == true
      @user.update_attributes(activated_at: DateTime.now.in_time_zone(Time.zone))
    end
    redirect_to users_path, notice: t('.successfully_disable')
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :roles, :start_date,
                                :job_title, :department_id, :mobile, :date_of_birth,
                                :province_id, :email, :password, :password_confirmation, :gender,
                                :manager_id, :calendar_integration, :pin_code, client_ids: [],
                                case_worker_attributes: [:id, :client_id, :readable, :editable],
                                custom_field_permissions_attributes: [:id, :custom_field_id, :readable, :editable],
                                program_stream_permissions_attributes: [:id, :program_stream_id, :readable, :editable],
                                quantitative_type_permissions_attributes: [:id, :quantitative_type_id, :readable, :editable],
                                permission_attributes: [:id, :case_notes_readable, :case_notes_editable, :assessments_readable, :assessments_editable])
  end

  def find_user
    @user = User.find(params[:id])
  end

  def find_association
    @department = Department.order(:name)
    @province   = Province.order(:name)
    @managers   = User.managers.order(:first_name, :last_name)
    @managers   = @managers.where.not('id = :user_id OR manager_ids && ARRAY[:user_id]', { user_id: @user.id }) if params[:action] == 'edit' || params[:action] == 'update'
  end
end
