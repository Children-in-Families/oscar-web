class UserCustomFieldsController < AdminController
  before_action :set_user, :set_custom_field

  def edit
  end

  def update
    if @user_custom_field.update(merged_custom_field_params)
      redirect_to user_user_custom_field_path(@user, @user_custom_field), notice: 'Succesfully save information'
    else
      render :edit
    end
  end

  def show
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
      @user_custom_field = @user.user_custom_fields.find(params[:id])
    end
end
