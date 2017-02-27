class UserCustomFieldsController < AdminController
  load_and_authorize_resource

  before_action :set_user
  before_action :set_custom_field, only: [:new, :index, :destroy]
  before_action :set_user_custom_field, only: [:edit, :show, :destroy]

  def edit
  end

  def update
    if @user_custom_field.update(merged_custom_field_params)
      redirect_to user_user_custom_fields_path(@user, custom_field_id: @user_custom_field.custom_field_id), notice: t('.successfully_created')
    else
      render :edit
    end
  end

  def show
  end

  def new
    @user_custom_field = @user.user_custom_fields.new(custom_field: @custom_field)
    @user_custom_field.save
  end

  def index
    @user_custom_field = @user.user_custom_fields.where(custom_field: @custom_field).order(created_at: :desc).page(params[:page]).per(4)
  end

  def destroy
    @user_custom_field.destroy
    redirect_to user_user_custom_fields_path(@user, custom_field_id: @custom_field.id), notice: t('.successfully_deleted')
  end

  private

  def custom_field_params
    params.require(:user_custom_field).permit(:properties)
  end

  def merged_custom_field_params
    if params['user_custom_field']['properties'].present?
      custom_field_params.merge(properties: (params['user_custom_field']['properties']).to_json)
    else
      custom_field_params
    end
  end

  protected

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_custom_field
    @custom_field = CustomField.find(params['custom_field_id'])
  end

  def set_user_custom_field
    @user_custom_field = @user.user_custom_fields.find(params[:id])
  end
end
