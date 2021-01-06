class EnrollmentTrackingsController < AdminController
  load_and_authorize_resource

  include EnrollmentTrackingsConcern

  before_action :find_entity, :find_enrollment, :find_program_stream
  before_action :find_enrollment_tracking, only: :show
  before_action -> { check_user_permission('readable') }, only: :show

  def show
  end
end
