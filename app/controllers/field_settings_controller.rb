class FieldSettingsController < AdminController
  def index
    @field_settings = FieldSetting.order(:group, :name)
  end

  def update
    @field_setting = FieldSetting.find(params[:id])

    @field_setting.update(params.require(:field_setting).permit(:label, :visible))
    I18n.backend.reload_custom_labels

    redirect_to field_settings_path, notice: t('.successfully_updated')
  end
end
