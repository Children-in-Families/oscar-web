class DashboardsController < AdminController
  def index
    @dashboard = Dashboard.new(Client.accessible_by(current_ability))
  end
end
