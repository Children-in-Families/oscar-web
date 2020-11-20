class EnrollmentsController < AdminController
  load_and_authorize_resource

  include EnrollmentConcern

  before_action :find_entity

  def index
    program_streams = ProgramStreamDecorator.decorate_collection(ordered_program)
    @program_streams = Kaminari.paginate_array(program_streams).page(params[:page]).per(20)
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

    enrollments_exited    = all_programs.inactive_enrollments(@programmable).complete
    enrollments_inactive  = all_programs.without_status_by(@programmable).complete
    program_streams       = enrollments_exited + enrollments_inactive
  end
end
