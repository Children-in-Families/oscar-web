class RefereesController < AdminController
  load_and_authorize_resource

  def index
    @referees_grid = RefereesGrid.new(params[:referees_grid]) do |scope|
      scope.page(params[:page]).page(params[:page]).per(20)
    end

    respond_to do |f|
      f.html do
        @referees_grid
      end
      f.xls do
        send_data  @referees_grid.to_xls, filename: "referees_report-#{Time.now}.xls"
      end
    end
  end
end

