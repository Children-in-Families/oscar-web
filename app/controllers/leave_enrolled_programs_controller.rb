class LeaveEnrolledProgramsController < AdminController
  load_and_authorize_resource :LeaveProgram

  include LeaveProgramsConcern

  def new
    @leave_program = @enrollment.build_leave_program
  end

  def create
    @leave_program = @enrollment.create_leave_program(leave_program_params)
    if @leave_program.save
      redirect_to client_client_enrolled_program_leave_enrolled_program_path(@client, @enrollment, @leave_program), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @leave_program.update_attributes(leave_program_params)
      redirect_to client_client_enrolled_program_leave_enrolled_program_path(@client, @enrollment, @leave_program), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def show
  end
end
