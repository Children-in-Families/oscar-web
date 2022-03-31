class FieldSettingsController < AdminController
  def index
    @field_settings = FieldSetting.cache_query_find_by_ngo_name
  end

  def bulk_update
    params.require(:field_setting).each do |id, attributes|
      FieldSetting.update(id, attributes.permit(:label, :visible))
    end

    I18n.backend.reload!

    redirect_to field_settings_path, notice: t('field_settings.update.successfully_updated')
  end
end
