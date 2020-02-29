class FieldSettingsController < AdminController
  def index
    @field_settings = FieldSetting.all
  end

  def update

  end
end
