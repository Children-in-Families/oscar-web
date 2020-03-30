class FieldSettingsController < AdminController
  def index
    @field_settings = FieldSetting.where('for_instances IS NULL OR for_instances iLIKE ?', "#{current_organization.short_name}").order(:group, :name)
  end

  def update
    @field_setting = FieldSetting.find(params[:id])
    @field_setting.update(params.require(:field_setting).permit(:label, :visible))
    I18n.backend.override_translation

    redirect_to field_settings_path, notice: t('.successfully_updated')
  end
end
