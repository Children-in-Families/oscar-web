class UsersController < AdminController
  load_and_authorize_resource

  before_action :find_user, only: [:show, :edit, :update, :destroy]
  before_action :find_association, except: [:index, :destroy]
  before_action :set_custom_form, only: [:new, :create, :edit, :update]

  def index
    @user_grid = UserGrid.new(params[:user_grid])
    respond_to do |f|
      f.html do
        @results = @user_grid.assets.size
        @user_grid.scope { |scope| scope.page(params[:page]).per(20) }
      end
      f.xls do
        send_data @user_grid.to_xls, filename: "user_report-#{Time.now}.xls"
      end
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def show
    @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(current_user: @user)) do |scope|
      scope.where(user_id: @user.id)
    end
    @results = @client_grid.assets.size
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      redirect_to @user, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @user.no_any_associated_objects?
      @user.destroy
      redirect_to users_url, notice: t('.successfully_deleted')
    else
      redirect_to users_url, alert: t('.alert')
    end
  end

  def version
    @user     = User.find(params[:user_id])
    @versions = @user.versions.reorder(created_at: :desc)
  end

  def disable
    @user = User.find(params[:user_id])
    redirect_to users_path, notice: t('.successfully_disable') if @user.update_attributes(disable: !@user.disable)
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :roles, :start_date,
                                :job_title, :department_id, :mobile, :date_of_birth,
                                :province_id, :email, :password,
                                :password_confirmation, custom_field_ids: [])
  end

  def set_custom_form
    @custom_field = CustomField.find_by(entity_type: 'User')
  end

  def find_user
    @user = User.find(params[:id])
  end

  def find_association
    @department = Department.order(:name)
    @province   = Province.order(:name)
  end
end
