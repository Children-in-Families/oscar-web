class LeaveProgramsController < AdminController
  load_and_authorize_resource

  include LeaveProgramsConcern
  include FormBuilderAttachments

  before_action :find_client, :find_enrollment, :find_program_stream
  before_action :find_client_histories, only: [:new, :create, :edit, :update]
  before_action :find_leave_program, only: [:show, :edit, :update, :destroy]
  before_action :get_attachments, only: [:edit, :update]
  before_action :initial_attachments, only: [:new, :create]
  before_action -> { check_user_permission('editable') }, except: :show
  before_action -> { check_user_permission('readable') }, only: :show

  def edit
    check_user_permission('editable')
    authorize @leave_program
  end

  def update
    authorize @leave_program
    if @leave_program.update_attributes(leave_program_params)
      add_more_attachments(@leave_program)
      redirect_to client_client_enrollment_leave_program_path(@client, @enrollment, @leave_program), notice: t('.successfully_updated')
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

  def find_client_histories
    enter_ngos = @client.enter_ngos
    exit_ngos  = @client.exit_ngos
    cps_enrollments = @client.client_enrollments
    cps_leave_programs = LeaveProgram.joins(:client_enrollment).where("client_enrollments.client_id = ?", @client.id)
    referrals = @client.referrals
    @case_histories = (enter_ngos + exit_ngos + cps_enrollments + cps_leave_programs + referrals).sort { |current_record, next_record| -([current_record.created_at, current_record.new_date] <=> [next_record.created_at, next_record.new_date]) }
  end
end
