class ClientEnrolledProgramsController < AdminController
  load_and_authorize_resource :ClientEnrollment

  include ClientEnrollmentConcern
  include FormBuilderAttachments

  before_action :find_client
  before_action :find_program_stream, except: :index
  before_action :find_client_histories, only: [:new, :create, :edit, :update]
  before_action :find_client_enrollment, only: [:show, :edit, :update, :destroy]
  before_action :get_attachments, only: [:new, :edit, :update, :create]
  before_action -> { check_user_permission('editable') }, except: [:index, :show, :report]
  before_action -> { check_user_permission('readable') }, only: :show

  def index
    program_streams = ProgramStreamDecorator.decorate_collection(ordered_program)
    @program_streams = Kaminari.paginate_array(program_streams).page(params[:page]).per(20)
  end

  def edit
  end

  def update
    if @client_enrollment.update_attributes(client_enrollment_params)
      add_more_attachments(@client_enrollment)
      redirect_to client_client_enrolled_program_path(@client, @client_enrollment, program_stream_id: @program_stream), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    name = params[:file_name]
    index = params[:file_index].to_i

    if name.present? && index.present?
      delete_form_builder_attachment(@client_enrollment, name, index)
      redirect_to request.referer, notice: t('.delete_attachment_successfully')
    else
      @client_enrollment.destroy_fully!
      redirect_to report_client_client_enrolled_programs_path(@client, program_stream_id: @program_stream), notice: t('.successfully_deleted')
    end
  end

  def report
    @enrollments = @program_stream.client_enrollments.where(client_id: @client).order(created_at: :DESC)
  end

  private

  def program_stream_order_by_enrollment
    if current_user.admin? || current_user.strategic_overviewer?
      all_programs = ProgramStream.with_deleted.all
    else
      all_programs = ProgramStream.with_deleted.where(id: current_user.program_stream_permissions.where(readable: true).pluck(:program_stream_id))
    end
    all_programs.active_enrollments(@client).complete
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
