class EnrolledProgramsController < AdminController
  load_and_authorize_resource :Enrollment

  include EnrollmentConcern
  include FormBuilderAttachments

  before_action :find_entity
  before_action :find_program_stream, except: :index
  before_action :find_enrollment, only: [:show, :edit, :update, :destroy]
  before_action :get_attachments, only: [:edit, :update]

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
      if params[:family_id]
        path = family_enrolled_program_path(@programmable, @enrollment, program_stream_id: @program_stream)
      elsif params[:community_id]
        path = community_enrolled_program_path(@programmable, @enrollment, program_stream_id: @program_stream)
      end
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
      if params[:family_id]
        path = report_family_enrolled_programs_path(@programmable, program_stream_id: @program_stream)
      elsif params[:community_id]
        path = report_community_enrolled_programs_path(@programmable, program_stream_id: @program_stream)
      end
      redirect_to path, notice: t('.successfully_deleted')
    end
  end

  def report
    @enrollments = @program_stream.enrollments.where(programmable_id: @programmable.id).order(created_at: :DESC)
  end

  private

  def program_stream_order_by_enrollment
    if current_user.admin? || current_user.strategic_overviewer?
      all_programs = ProgramStream.with_deleted.where(entity_type: @entity_type)
    else
      all_programs = ProgramStream.with_deleted.where(entity_type: @entity_type).where(id: current_user.program_stream_permissions.where(readable: true).pluck(:program_stream_id))
    end

    enrollments_exited = all_programs.inactive_enrollments(@programmable, true).complete
    enrollments_inactive = all_programs.without_status_by(@programmable, true).complete
    @active_enrollments = all_programs.active_enrollments(@programmable, true).complete

    program_streams = (enrollments_exited + enrollments_inactive + @active_enrollments).uniq
  end
end
