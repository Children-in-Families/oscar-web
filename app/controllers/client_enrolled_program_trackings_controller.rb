class ClientEnrolledProgramTrackingsController < AdminController
  load_and_authorize_resource :ClientEnrollmentTracking

  include ClientEnrollmentTrackingsConcern

  def index
    @tracking_grid = ClientEnrolledProgramTrackingGrid.new(params[:tracking_grid])
    @tracking_grid.scope { |scope| scope.where(program_stream_id: @program_stream).page(params[:page]).per(20) }
  end

  def new
    @client_enrollment_tracking = @enrollment.client_enrollment_trackings.new
    authorize @client_enrollment_tracking
  end

  def create
    @client_enrollment_tracking = @enrollment.client_enrollment_trackings.new(client_enrollment_tracking_params)
    authorize @client_enrollment_tracking

    if @client_enrollment_tracking.save
      redirect_to report_client_client_enrolled_program_client_enrolled_program_trackings_path(@client, @enrollment, tracking_id: @tracking.id), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
    authorize @client_enrollment_tracking
  end

  def show
  end

  def update
    authorize @client_enrollment_tracking
    if @client_enrollment_tracking.update_attributes(client_enrollment_tracking_params)
      redirect_to report_client_client_enrolled_program_client_enrolled_program_trackings_path(@client, @enrollment, tracking_id: @tracking.id), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @client_enrollment_tracking.destroy
    redirect_to report_client_client_enrolled_program_client_enrolled_program_trackings_path(@client, @enrollment, tracking_id: @tracking.id), notice: t('.successfully_deleted')
  end

  def report
    @client_enrollment_trackings = @enrollment.client_enrollment_trackings.enrollment_trackings_by(@tracking)
  end
end
