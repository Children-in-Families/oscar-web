class TrackingsController < AdminController
  before_action :find_client, :find_enrollment, :find_program_stream

  def new
    @tracking = @enrollment.trackings.new
  end

  def create
    tracking = @enrollment.trackings.new(tracking_params)
    if tracking.save
      redirect_to client_client_enrollments_path(@client), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def show
    @tracking = @enrollment.trackings.find(params[:id])
  end

  private

  def tracking_params
    params.require(:tracking).permit({}).merge(properties: params[:tracking][:properties])
  end

  def find_client
    @client = Client.friendly.find params[:client_id]
  end

  def find_enrollment
    @enrollment = @client.client_enrollments.find params[:client_enrollment_id]
  end

  def find_program_stream
    @program_stream = @enrollment.program_stream
  end
end
