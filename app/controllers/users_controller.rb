class UsersController < AdminController
  load_and_authorize_resource

  before_action :find_user, only: [:show, :edit, :update, :destroy]
  before_action :find_association, except: [:index, :destroy]

  def index
    @user_grid = UserGrid.new(params[:user_grid])
    respond_to do |f|
      f.html do
        @user_grid.scope { |scope| scope.paginate(page: params[:page], per_page: 20) }
      end
      f.csv do
        send_data @user_grid.to_csv, type: 'text/csv',
                                     disposition: 'inline',
                                     filename: "user_report-#{Time.now}.csv"
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
    if @user.has_no_any_associated_objects?
      @user.destroy
      redirect_to users_url, notice: t('.successfully_deleted')
    else
      redirect_to users_url, alert: t('.alert')
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :roles, :start_date, :job_title, :department_id, :mobile, :date_of_birth, :province_id, :email, :password, :password_confirmation)
  end

  def find_user
    @user = User.find(params[:id])
  end

  def find_association
    @department = Department.order(:name)
    @province   = Province.order(:name)
  end
end
