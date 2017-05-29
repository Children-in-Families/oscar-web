class ClientEnrollmentsController < AdminController
  before_action :find_client
  before_action :find_program_stream, except: :index

  def index
    @program_streams = ProgramStream.all
  end

  def new
    @client_enrollment = @client.client_enrollments.new(program_stream_id: @program_stream)
  end
  
  def show
  end

  def create
    client_enrollment = @client.client_enrollments.new(client_enrollment_params)
    if client_enrollment.save
      redirect_to client_client_enrollments_path(@client), notice: t('.successfully_created')
    else
      redirect_to :new
    end
  end
  
  def destroy
    
  end

  private

  def client_enrollment_params
    params.require(:client_enrollment).permit({}).merge(properties: params[:client_enrollment][:properties], program_stream_id: params[:program_stream_id])
  end

  def find_client
    @client = Client.friendly.find(params[:client_id])
  end

  def find_program_stream
    @program_stream = ProgramStream.find(params[:program_stream_id])
  end
end
