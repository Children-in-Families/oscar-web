class ClientEnrolledProgramLeaveProgramsController < AdminController
  load_and_authorize_resource :LeaveProgram

  before_action :find_client, :find_enrollment, :find_program_stream
  before_action :find_leave_program, only: [:show, :edit, :update, :destroy]

  def new
    @leave_program = @enrollment.build_leave_program
  end

  def create
    @leave_program = @enrollment.create_leave_program(leave_program_params)
    if @leave_program.save
      redirect_to client_client_enrolled_program_client_enrolled_program_leave_program_path(@client, @enrollment, @leave_program), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @leave_program.update_attributes(leave_program_params)
      redirect_to client_client_enrolled_program_client_enrolled_program_leave_program_path(@client, @enrollment, @leave_program), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def show
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
    @enrollment = @client.client_enrollments.find params[:client_enrolled_program_id]
  end

  def find_program_stream
    @program_stream = @enrollment.program_stream
  end

  def find_leave_program
    @leave_program = @enrollment.leave_program
  end
end
