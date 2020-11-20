class EnrolledProgramsController < AdminController
  # load_and_authorize_resource :Enrollment

  # include EnrollmentConcern

  # before_action :find_entity

  # def index
  #   program_streams = ProgramStreamDecorator.decorate_collection(ordered_program)
  #   @program_streams = Kaminari.paginate_array(program_streams).page(params[:page]).per(20)
  # end
end
