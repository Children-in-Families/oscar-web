class LeaveProgramsController < AdminController
  load_and_authorize_resource

  before_action :find_client, :find_enrollment, :find_program_stream

  def new
    @leave_program = @enrollment.build_leave_program
  end

  def create
    @leave_program = @enrollment.create_leave_program(leave_program_params)
    if @leave_program.save
      # @leave_program.client_enrollment.update_columns(status: 'Exited')
      # @client.update_attributes(status: client_status) if client_status.present?
      redirect_to client_client_enrollment_leave_program_path(@client, @enrollment, @leave_program, program_streams: params[:program_streams]), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @leave_program.update_attributes(leave_program_params)
      redirect_to client_client_enrollment_leave_program_path(@client, @enrollment, @leave_program, program_streams: params[:program_streams]), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def show
    @leave_program = @enrollment.leave_program
  end

  private

  def leave_program_params
    params[:leave_program][:properties].keys.each do |k|
      params[:leave_program][:properties][k].delete('') if params[:leave_program][:properties][k].class == Array && params[:leave_program][:properties][k].count > 1
    end
    params.require(:leave_program).permit(:exit_date, {}).merge(properties: params[:leave_program][:properties], program_stream_id: params[:program_stream_id])
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

  def client_status
    case_status = @client.cases.exclude_referred.current.case_type
    status = "Active #{case_status}" if ProgramStream.active_enrollments(@client).count == 0
  end
end
