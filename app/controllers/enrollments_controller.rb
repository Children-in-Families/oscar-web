class EnrollmentsController < AdminController
  load_and_authorize_resource

  include EnrollmentConcern
  include FormBuilderAttachments

  before_action :find_entity
  before_action :find_entity_histories, only: [:new, :create, :edit, :update]
  before_action :find_program_stream, except: :index
  before_action :find_enrollment, only: [:show, :edit, :update, :destroy]

  def index
    program_streams = ProgramStreamDecorator.decorate_collection(ordered_program)
    @program_streams = Kaminari.paginate_array(program_streams).page(params[:page]).per(20)
  end

  def new
    if @program_stream.has_rule?
      if @program_stream.has_program_exclusive? || @program_stream.has_mutual_dependence?
        enrollment_index_path unless valid_entity? && valid_program?
      else
        enrollment_index_path unless valid_entity?
      end
    elsif @program_stream.has_program_exclusive? || @program_stream.has_mutual_dependence?
      enrollment_index_path unless valid_program?
    end
    authorize(@programmable) && authorize(@enrollment)
    @enrollment = @programmable.enrollments.new(program_stream_id: @program_stream.id)
    @attachment = @enrollment.form_builder_attachments.build
  end

  def create
    @enrollment = @programmable.enrollments.new(enrollment_params)
    authorize(@programmable) && authorize(@enrollment)
    if @enrollment.save
      path = params[:family_id] ? family_enrolled_program_path(@programmable, @enrollment, program_stream_id: @program_stream) : '#'
      redirect_to path, notice: t('.successfully_created')
    else
      render :new
    end
  end

  private

  def program_stream_order_by_enrollment
    program_streams = []
    if current_user.admin? || current_user.strategic_overviewer?
      all_programs = ProgramStream.all
    else
      all_programs = ProgramStream.where(id: current_user.program_stream_permissions.where(readable: true, user: current_user).pluck(:program_stream_id))
    end
    all_programs = params[:family_id] ? all_programs.attached_with('Family') : all_programs.attached_with('Client')

    enrollments_exited    = all_programs.inactive_enrollments(@programmable, true).complete
    enrollments_inactive  = all_programs.without_status_by(@programmable, true).complete
    program_streams       = enrollments_exited + enrollments_inactive
  end

  def find_entity_histories
    # enter_ngos = @programmable.enter_ngos
    # exit_ngos  = @programmable.exit_ngos
    cps_enrollments = @programmable.enrollments
    # cps_leave_programs = LeaveProgram.joins(:enrollment).where("enrollments.programmable_id = ?", @programmable.id)
    # referrals = @programmable.referrals
    # @case_histories = (enter_ngos + exit_ngos + cps_enrollments + cps_leave_programs + referrals).sort { |current_record, next_record| -([current_record.created_at, current_record.new_date] <=> [next_record.created_at, next_record.new_date]) }
    @case_histories = (cps_enrollments).sort { |current_record, next_record| -([current_record.created_at, current_record.new_date] <=> [next_record.created_at, next_record.new_date]) }
  end
end
