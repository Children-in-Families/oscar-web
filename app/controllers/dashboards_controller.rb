class DashboardsController < AdminController
  def index
    @dashboard = Dashboard.new(current_user)
  end
end
