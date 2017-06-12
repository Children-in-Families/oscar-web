class ClientEnrollmentTrackingsController < AdminController
  load_and_authorize_resource
  
  before_action :find_client, :find_enrollment, :find_program_stream
  before_action :find_tracking, except: [:index, :show]
  before_action :find_client_enrollment_tracking, only: [:show, :update, :destroy]

  def index
    @tracking_grid = TrackingGrid.new(params[:tracking_grid])
    @tracking_grid.scope { |scope| scope.where(program_stream_id: @program_stream).page(params[:page]).per(20) }
  end

  def new
    @client_enrollment_tracking = @enrollment.client_enrollment_trackings.new
  end

  def create
    @client_enrollment_tracking = @enrollment.client_enrollment_trackings.new(client_enrollment_tracking_params)
    if @client_enrollment_tracking.save
      redirect_to report_client_client_enrollment_client_enrollment_trackings_path(@client, @enrollment, tracking_id: @tracking.id), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def show
  end

  def update
    if @client_enrollment_tracking.update_attributes(client_enrollment_tracking_params)
      redirect_to report_client_client_enrollment_client_enrollment_trackings_path(@client, @enrollment, tracking_id: @tracking.id), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @client_enrollment_tracking.destroy
    redirect_to report_client_client_enrollment_client_enrollment_trackings_path(@client, @enrollment, tracking_id: @tracking.id), notice: t('.successfully_deleted')
  end

  def report
    @client_enrollment_trackings = @enrollment.client_enrollment_trackings
  end

  private

  def client_enrollment_tracking_params
    params.require(:client_enrollment_tracking).permit({}).merge(properties: params[:client_enrollment_tracking][:properties], tracking_id: params[:tracking_id])
  end

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find params[:client_id]
  end

  def find_enrollment
    @enrollment = @client.client_enrollments.find params[:client_enrollment_id]
  end

  def find_program_stream
    @program_stream = @enrollment.program_stream
  end

  def find_tracking
    @tracking = @program_stream.trackings.find params[:tracking_id]
  end

  def find_client_enrollment_tracking
    @client_enrollment_tracking = @enrollment.client_enrollment_trackings.find params[:id]
  end
end
