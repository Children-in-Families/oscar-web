class ProgramStreamsController < AdminController
  load_and_authorize_resource
  
  before_action :find_program_stream, except: [:index, :new, :create]

  def index
    @program_stream_grid = ProgramStreamGrid.new(params[:program_stream_grid])
    @results = @program_stream_grid.assets.size
    @program_stream_grid.scope { |scope| scope.ordered.page(params[:page]).per(20) }
  end

  def new
    @program_stream = ProgramStream.new
    @tracking = @program_stream.trackings.build
  end

  def edit
  end

  def show
  end

  def create
    @program_stream = ProgramStream.new(program_stream_params)
    if @program_stream.save
      redirect_to program_streams_path, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def update
    if @program_stream.update_attributes(program_stream_params)
      redirect_to program_streams_path, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @program_stream.destroy
    redirect_to program_streams_path, notice: t('.successfully_deleted')
  end

  private

  def find_program_stream
    @program_stream = ProgramStream.find(params[:id])
  end

  def program_stream_params
    params.require(:program_stream).permit(:name, :rules, :description, :enrollment, :tracking, :frequency, :time_of_frequency, :exit_program, :quantity, domain_ids: []).merge(trackings_attributes:  params[:program_stream][:trackings_attributes])
  end
end