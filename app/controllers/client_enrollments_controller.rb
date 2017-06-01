class ClientEnrollmentsController < AdminController
  before_action :find_client
  before_action :find_program_stream, except: :index
  before_action :find_client_enrollment, only: :show

  def index
    @client_enrollment_grid = ClientEnrollmentGrid.new(params[:client_enrollment_grid])
    @results = @client_enrollment_grid.assets.size
    @client_enrollment_grid.scope { |scope| scope.page(params[:page]).per(20) }
  end

  def new
    if valid_client?
      @client_enrollment = @client.client_enrollments.new(program_stream_id: @program_stream)
    else
      redirect_to client_client_enrollments_path(@client), notice: t('.client_not_valid')
    end
  end
  
  def show
  end

  def create
    @client_enrollment = @client.client_enrollments.new(client_enrollment_params)
    if @client_enrollment.save
      redirect_to client_client_enrollments_path(@client), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def report
    @enrollments = ClientEnrollment.enrollments_by(@client, @program_stream).order(:created_at)
  end

  private

  def client_enrollment_params
    params.require(:client_enrollment).permit({}).merge(properties: params[:client_enrollment][:properties], program_stream_id: params[:program_stream_id])
  end

  def find_client_enrollment
    @client_enrollment = @client.client_enrollments.find(params[:id])
  end

  def find_client
    @client = Client.friendly.find(params[:client_id])
  end

  def find_program_stream
    @program_stream = ProgramStream.find(params[:program_stream_id])
  end

  def client_filtered
    AdvancedSearches::ClientAdvancedSearch.new(@program_stream.rules, {}, Client.all).filter
  end

  def valid_client?
    client_filtered.ids.include? @client.id
  end
end
