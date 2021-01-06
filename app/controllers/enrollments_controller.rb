class EnrollmentsController < AdminController
  load_and_authorize_resource

  include EnrollmentConcern
  include FormBuilderAttachments

  before_action :find_entity
  before_action :find_program_stream, except: :index
  before_action :find_enrollment, only: [:show, :edit, :update, :destroy]
  before_action :get_attachments, only: [:new, :edit, :update, :create]
  before_action -> { check_user_permission('editable') }, except: [:index, :show, :report]
  before_action -> { check_user_permission('readable') }, only: :show

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

  def edit
    authorize @enrollment
  end

  def update
    authorize @enrollment
    if @enrollment.update_attributes(enrollment_params)
      add_more_attachments(@enrollment)
      path = params[:family_id] ? family_enrollment_path(@programmable, @enrollment, program_stream_id: @program_stream) : '#'
      redirect_to path, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def show
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

  def destroy
    name = params[:file_name]
    index = params[:file_index].to_i

    if name.present? && index.present?
      delete_form_builder_attachment(@enrollment, name, index)
      redirect_to request.referer, notice: t('.delete_attachment_successfully')
    else
      @enrollment.destroy_fully!
      path = params[:family_id] ? report_family_enrollments_path(@programmable, program_stream_id: @program_stream) : '#'
      redirect_to path, notice: t('.successfully_deleted')
    end
  end

  def report
    @enrollments = @program_stream.enrollments.enrollments_by(@programmable).order(created_at: :DESC)
  end

  private

  def program_stream_order_by_enrollment
    program_streams = []
    if current_user.admin? || current_user.strategic_overviewer?
      all_programs = ProgramStream.all
    else
      all_programs = ProgramStream.where(id: current_user.program_stream_permissions.where(readable: true, user: current_user).pluck(:program_stream_id))
    end
    all_programs = params[:family_id] ? all_programs.attached_with('Family') : all_programs
    polymorphic = params[:family_id].present?
    enrollments_exited    = all_programs.inactive_enrollments(@programmable, polymorphic).complete
    enrollments_inactive  = all_programs.without_status_by(@programmable, polymorphic).complete
    program_streams       = enrollments_exited + enrollments_inactive
  end
end
