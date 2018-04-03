class LeaveEnrolledProgramsController < AdminController
  load_and_authorize_resource :LeaveProgram

  include LeaveProgramsConcern
  include FormBuilderAttachments

  before_action :find_client, :find_enrollment, :find_program_stream
  before_action :find_leave_program, only: [:show, :edit, :update, :destroy]
  before_action :get_attachments, only: [:edit, :update]
  before_action :initial_attachments, only: [:new, :create]
  before_action -> { check_user_permission('editable') }, except: :show
  before_action -> { check_user_permission('readable') }, only: :show

  def new
    # @leave_program = @enrollment.build_leave_program
    # @attachment    = @leave_program.form_builder_attachments.build
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
    check_user_permission('editable')
  end

  def update
    if @leave_program.update_attributes(leave_program_params)
      add_more_attachments(@leave_program)
      redirect_to client_client_enrolled_program_leave_enrolled_program_path(@client, @enrollment, @leave_program), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def show
    check_user_permission('readable')
  end

  def destroy
    name = params[:file_name]
    index = params[:file_index].to_i
    params_program_streams = params[:program_streams]
    if name.present? && index.present?
      delete_form_builder_attachment(@leave_program, name, index)
    end
    redirect_to request.referer, notice: t('.delete_attachment_successfully')
  end
end
