class EnrolledProgramsController < AdminController
  load_and_authorize_resource :Enrollment

  include EnrollmentConcern
  include FormBuilderAttachments

  before_action :find_entity
  before_action :find_program_stream, except: :index
  before_action :find_entity_histories, only: [:new, :create, :edit, :update]
  before_action :find_enrollment, only: [:show, :edit, :update, :destroy]

  def index
    program_streams = ProgramStreamDecorator.decorate_collection(ordered_program)
    @program_streams = Kaminari.paginate_array(program_streams).page(params[:page]).per(20)
  end

  def show
  end

  def edit
  end

  def update
    if @enrollment.update_attributes(enrollment_params)
      add_more_attachments(@enrollment)
      path = params[:family_id] ? family_enrolled_program_path(@programmable, @enrollment, program_stream_id: @program_stream) : '#'
      redirect_to path, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    name = params[:file_name]
    index = params[:file_index].to_i

    if name.present? && index.present?
      delete_form_builder_attachment(@enrollment, name, index)
      redirect_to request.referer, notice: t('.delete_attachment_successfully')
    else
      @enrollment.destroy_fully!
      path = params[:family_id] ? report_family_enrolled_programs_path(@programmable, program_stream_id: @program_stream) : '#'
      redirect_to path, notice: t('.successfully_deleted')
    end
  end

  def report
    @enrollments = @program_stream.enrollments.where(programmable_id: @programmable.id).order(created_at: :DESC)
  end

  private

  def program_stream_order_by_enrollment
    if current_user.admin? || current_user.strategic_overviewer?
      all_programs = ProgramStream.with_deleted.all
    else
      all_programs = ProgramStream.with_deleted.where(id: current_user.program_stream_permissions.where(readable: true).pluck(:program_stream_id))
    end
    all_programs.active_enrollments(@programmable, true).complete
  end

  def find_entity_histories
    # enter_ngos = @programmable.enter_ngos
    # exit_ngos  = @programmable.exit_ngos
    cps_enrollments = @programmable.enrollments
    # cps_leave_programs = LeaveProgram.joins(:client_enrollment).where("client_enrollments.client_id = ?", @programmable.id)
    # referrals = @programmable.referrals
    # @case_histories = (enter_ngos + exit_ngos + cps_enrollments + cps_leave_programs + referrals).sort { |current_record, next_record| -([current_record.created_at, current_record.new_date] <=> [next_record.created_at, next_record.new_date]) }
    @case_histories = (cps_enrollments).sort { |current_record, next_record| -([current_record.created_at, current_record.new_date] <=> [next_record.created_at, next_record.new_date]) }
  end
end
