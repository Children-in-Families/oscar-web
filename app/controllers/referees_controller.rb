class RefereesController < AdminController
  load_and_authorize_resource
  before_action :find_referee, except: :index

  def index
    @referees_grid = RefereesGrid.new(params[:referees_grid])
    @results        = @referees_grid.assets.size
    respond_to do |f|
      f.html do
        @referees_grid.scope do |scope|
          scope.page(params[:page]).per(20)
        end
      end
      f.xls do
        send_data  @referees_grid.to_xls, filename: "referees_report-#{Time.now}.xls"
      end
    end
  end

  def show
  end

  private

    def find_referee
      @referee = Referee.find(params[:id])
    end
end

