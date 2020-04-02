class FieldSettingsController < AdminController
  def index
    @field_settings = FieldSetting.where('for_instances IS NULL OR for_instances iLIKE ?', "#{current_organization.short_name}").includes(:translations).order(:group, :name)
  end

  def bulk_update
    params.require(:field_setting).each do |id, attributes|
      FieldSetting.update(id, attributes.permit(:label, :visible))
    end

    I18n.backend.reload!

    redirect_to field_settings_path, notice: t('field_settings.update.successfully_updated')
  end
end
