class LeaveProgramsController < AdminController
  before_action :find_client, :find_enrollment, :find_program_stream

  def new
    @leave_program = @enrollment.build_leave_program
  end

  def create
    leave_program = @enrollment.create_leave_program(leave_program_params)
    if leave_program.save
      leave_program.client_enrollment.update_attributes(status: 'Exited')
      redirect_to client_client_enrollments_path(@client), notice: t('.successfully_created')
    else
      render :new
    end
  end

  private

  def leave_program_params
    params.require(:leave_program).permit({}).merge(properties: params[:leave_program][:properties])
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
