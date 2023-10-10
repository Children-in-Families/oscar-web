class FieldSettingsController < AdminController
  def index
    @field_settings = FieldSetting.where('for_instances IS NULL OR for_instances iLIKE ?', "#{Apartment::Tenant.current}").includes(:translations).order(:form_group_1, :name)
  end

  def bulk_update
    params.require(:field_setting).each do |id, attributes|
      I18n.with_locale(:en) do
        FieldSetting.update(id, label: attributes.dig(:label))
      end

      local_locale = Organization.current.local_language

      if local_locale.present?
        I18n.with_locale(local_locale) do
          FieldSetting.update(id, label: attributes.dig(:local_label))
        end
      end
    end

    I18n.backend.reload!

    redirect_to field_settings_path, notice: t('field_settings.update.successfully_updated')
  end
end
