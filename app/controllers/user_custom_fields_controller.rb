class UserCustomFieldsController < AdminController
  load_and_authorize_resource

  before_action :set_user
  before_action :set_custom_field
  before_action :set_user_custom_field, only: [:edit, :show, :destroy]

  def index
    @user_custom_fields = @user.user_custom_fields.by_custom_field(@custom_field).order(created_at: :desc).page(params[:page]).per(4)
    redirect_to user_path(@user) if @user_custom_fields.blank?
  end

  def show
  end

  def new
    @user_custom_field = @user.user_custom_fields.new(custom_field_id: @custom_field.id)
  end

  def create
    @user_custom_field                 = @user.user_custom_fields.new(user_custom_field_params)
    @user_custom_field.custom_field_id = @custom_field.id
    if @user_custom_field.save
      redirect_to user_user_custom_fields_path(@user, custom_field_id: @user_custom_field.custom_field.id), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user_custom_field.update(user_custom_field_params)
      redirect_to user_user_custom_fields_path(@user, custom_field_id: @user_custom_field.custom_field_id), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @user_custom_field.destroy
    redirect_to user_user_custom_fields_path(@user, custom_field_id: @custom_field.id), notice: t('.successfully_deleted')
  end

  private

  def user_custom_field_params
    params.require(:user_custom_field).permit({}).merge(properties: (params['user_custom_field']['properties']).to_json)
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_custom_field
    if action_name == 'edit' || action_name == 'update'
      @custom_field = @user_custom_field.custom_field
    elsif action_name == 'create'
      @custom_field = CustomField.find(params[:user_custom_field][:custom_field_id])
    else
      @custom_field = CustomField.find(params['custom_field_id'])
    end
  end

  def set_user_custom_field
    @user_custom_field = @user.user_custom_fields.find(params[:id])
  end
end
