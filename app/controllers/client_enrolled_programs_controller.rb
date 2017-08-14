class ClientEnrolledProgramsController < AdminController
  load_and_authorize_resource :ClientEnrollment

  before_action :find_client
  before_action :find_program_stream, except: :index
  before_action :find_client_enrollment, only: [:show, :edit, :update]

  def index
    program_streams = ProgramStreamDecorator.decorate_collection(ordered_program)
    @program_streams = Kaminari.paginate_array(program_streams).page(params[:page]).per(20)
  end

  def new
    if @program_stream.rules.present?
      if @program_stream.program_exclusive.any? || @program_stream.mutual_dependence.any?
        redirect_to client_client_enrolled_programs_path(@client), alert: t('.client_not_valid') unless valid_client? && valid_program?
      else
        redirect_to client_client_enrolled_programs_path(@client), alert: t('.client_not_valid') unless valid_client?
      end
    elsif @program_stream.mutual_dependence.any? || @program_stream.program_exclusive.any?
      redirect_to client_client_enrolled_programs_path(@client), alert: t('.client_not_valid') unless valid_program?
    end
    @client_enrollment = @client.client_enrollments.new(program_stream_id: @program_stream)
  end

  def edit
  end

  def update
    if @client_enrollment.update_attributes(client_enrollment_params)
      redirect_to client_client_enrolled_program_path(@client, @client_enrollment, program_stream_id: @program_stream), notice: t('.successfully_updated')
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
      redirect_to client_client_enrolled_program_path(@client, @client_enrollment, program_stream_id: @program_stream), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def destroy
    @client_enrollment.destroy
    redirect_to report_client_client_enrolled_programs_path(@client, program_stream_id: @program_stream), notice: t('.successfully_deleted')
  end

  def report
    @enrollments = @program_stream.client_enrollments.where(client_id: @client).order(created_at: :DESC)
  end

  private

  def client_enrollment_params
    params[:client_enrollment][:properties].keys.each do |k|
      params[:client_enrollment][:properties][k].delete('') if params[:client_enrollment][:properties][k].class == Array && params[:client_enrollment][:properties][k].count > 1
    end
    params.require(:client_enrollment).permit(:enrollment_date, {}).merge(properties: params[:client_enrollment][:properties], program_stream_id: params[:program_stream_id])
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
    ProgramStream.active_enrollments(@client).complete
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

  def valid_program?
    program_active_status_ids   = ProgramStream.active_enrollments(@client).pluck(:id)
    if @program_stream.program_exclusive.any? && @program_stream.mutual_dependence.any?
      (@program_stream.program_exclusive & program_active_status_ids).empty? && (@program_stream.mutual_dependence - program_active_status_ids).empty?
    elsif @program_stream.mutual_dependence.any?
      (@program_stream.mutual_dependence - program_active_status_ids).empty?
    elsif @program_stream.program_exclusive.any?
      (@program_stream.program_exclusive & program_active_status_ids).empty?
    end
  end
end
