class FieldSettingsController < AdminController
  def index
    @field_settings = FieldSetting.where('for_instances IS NULL OR for_instances iLIKE ?', "#{Apartment::Tenant.current}").includes(:translations).order(:form_group_1, :name)
  end

  def bulk_update
    params.require(:field_setting).each do |id, attributes|
      FieldSetting.update(id, attributes.permit(:label, :visible, :required))

      local_locale = Organization.current.local_language

      if local_locale.present?
        I18n.with_locale(local_locale) do
          FieldSetting.update(id, label: attributes.dig(:local_label))
        end
      end
    end

    redirect_to field_settings_path, notice: t('field_settings.update.successfully_updated')
  end
end
