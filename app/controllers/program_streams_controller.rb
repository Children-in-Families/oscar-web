class ProgramStreamsController < AdminController
  # load_and_authorize_resource

  def index

  end

  def new
    @program_stream = ProgramStream.new
  end

  def edit
    
  end

  def create
    @program_stream = ProgramStream.new(program_stream_params)
  end

  private

  def program_stream_params
    params.require(:program_stream).permit(:name)
  end

end