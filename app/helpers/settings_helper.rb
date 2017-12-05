module SettingsHelper
  def active_navigation(controller, action)
    'active' if controller == controller_name && action == action_name
  end

  def selected_country?(country)
    'selected' if params[:country] == country
  end
end
