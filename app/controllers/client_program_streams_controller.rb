class ClientProgramStreamsController < AdminController
  before_action :find_client, :find_program_stream, except: :index

  def index
    @program_streams = ProgramStream.all
  end

  def new
    @client_program_stream = @client.client_program_streams.new(program_stream_id: @program_stream)
    @enrollment = @client_program_stream.enrollments.build
  end
  
  def show
  end

  def create
    @client_program_streams = @client.client_program_streams.new(client_program_stream_params)
    if @client_program_streams.save
      redirect_to client_client_program_streams_path(@client), notice: t('.successfully_created')
    else
      redirect_to :new
    end
  end
  
  def destroy
    
  end

  private

  def client_program_stream_params
    params.require(:client_program_stream).permit({}).merge(enrollments_attributes: params[:client_program_stream][:enrollments_attributes], program_stream_id: params[:program_stream_id])
  end

  def find_client
    @client = Client.friendly.find(params[:client_id])
  end

  def find_program_stream
    @program_stream = ProgramStream.find(params[:program_stream_id])
  end
end
