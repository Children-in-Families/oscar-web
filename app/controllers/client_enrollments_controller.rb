class ClientEnrollmentsController < AdminController
  load_and_authorize_resource

  before_action :find_client
  before_action :find_program_stream, except: :index
  before_action :find_client_enrollment, only: [:show, :edit, :update]

  def index
    program_streams = ProgramStreamDecorator.decorate_collection(ordered_program)
    @program_streams = Kaminari.paginate_array(program_streams).page(params[:page]).per(20)
  end

  def new
    if @program_stream.rules.present?
      redirect_to client_client_enrollments_path(@client), alert: t('.client_not_valid') unless valid_client?
    end
    @client_enrollment = @client.client_enrollments.new(program_stream_id: @program_stream)
  end

  def edit
    authorize @client_enrollment
  end

  def update
    authorize @client_enrollment
    if @client_enrollment.update_attributes(client_enrollment_params)
      redirect_to client_client_enrollment_path(@client, @client_enrollment, program_stream_id: @program_stream), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def show
  end

  def create
    @client_enrollment = @client.client_enrollments.new(client_enrollment_params)
    authorize @client_enrollment
    if @client_enrollment.save
      redirect_to client_client_enrollment_path(@client, @client_enrollment, program_stream_id: @program_stream), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def destroy
    @client_enrollment.destroy
    redirect_to report_client_client_enrollments_path(@client, program_stream_id: @program_stream), notice: t('.successfully_deleted')
  end

  def report
    @enrollments = @program_stream.client_enrollments.enrollments_by(@client).order(:created_at)
  end

  private

  def client_enrollment_params
    params.require(:client_enrollment).permit({}).merge(properties: params[:client_enrollment][:properties], program_stream_id: params[:program_stream_id])
  end

  def find_client_enrollment
    @client_enrollment = @client.client_enrollments.find(params[:id])
  end

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def find_program_stream
    @program_stream = ProgramStream.find(params[:program_stream_id])
  end

  def client_filtered
    AdvancedSearches::ClientAdvancedSearch.new(@program_stream.rules, Client.all).filter
  end

  def program_stream_order_by_enrollment
    program_streams = []
    if params[:program_streams] == 'enrollment program streams'
      client_enrollments_with_status_active    = ProgramStream.enrollment_status_active(@client).completed
      program_streams = client_enrollments_with_status_active
    else
      client_enrollments_with_status_not_active    = ProgramStream.enrollment_status_not_active(@client).completed
      client_enrollments_without_status = ProgramStream.without_status_by(@client).completed
      program_streams = client_enrollments_with_status_not_active + client_enrollments_without_status
    end
    program_streams
  end

  def ordered_program
    column = params[:order]
    descending = params[:descending] == 'true'
    if column.present? && column != 'status'
      ordered = program_stream_order_by_enrollment.sort_by{ |ps| ps.send(column).to_s.downcase }
      descending ? ordered.reverse : ordered
    elsif column.present? && column == 'status'
      descending ? program_stream_order_by_enrollment.reverse : program_stream_order_by_enrollment
    else
      program_stream_order_by_enrollment
    end
  end

  def valid_client?
    client_filtered.ids.include? @client.id
  end
end
