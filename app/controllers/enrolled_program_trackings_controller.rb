class EnrolledProgramTrackingsController < AdminController
  load_and_authorize_resource :EnrollmentTracking

  include EnrollmentTrackingsConcern
  include FormBuilderAttachments

  before_action :find_entity, :find_enrollment, :find_program_stream
  before_action :find_tracking, except: [:index, :show, :destroy]
  before_action :find_enrollment_tracking, only: [:update, :destroy, :edit, :show]
  before_action :get_attachments, only: [:new, :create, :edit, :update]
  before_action -> { check_user_permission('editable') }, except: [:index, :show, :report]
  before_action -> { check_user_permission('readable') }, only: :show

  def index
    @tracking_grid = EnrolledProgramTrackingGrid.new(params[:tracking_grid])
    @tracking_grid.scope { |scope| scope.where(program_stream_id: @program_stream).page(params[:page]).per(20) }
  end

  def new
    @enrollment_tracking = @enrollment.enrollment_trackings.new
    @attachment          = @enrollment_tracking.form_builder_attachments.build
    authorize @enrollment_tracking
  end

  def create
    @enrollment_tracking = @enrollment.enrollment_trackings.new(enrollment_tracking_params)
    authorize @enrollment_tracking
    if @enrollment_tracking.save
      path = params[:family_id] ? report_family_enrolled_program_enrolled_program_trackings_path(@programmable, @enrollment, tracking_id: @tracking.id) : '#' 
      redirect_to path, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
    authorize @enrollment_tracking
  end

  def update
    authorize @enrollment_tracking
    if @enrollment_tracking.update_attributes(enrollment_tracking_params)
      add_more_attachments(@enrollment_tracking)
      path = params[:family_id] ? report_family_enrolled_program_enrolled_program_trackings_path(@programmable, @enrollment, tracking_id: @tracking.id) : '#'
      redirect_to path, notice: t('.successfully_updated')
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

    notice = ""
    if name.present? && index.present?
      delete_form_builder_attachment(@enrollment_tracking, name, index)
      redirect_to request.referer, notice: t('.delete_attachment_successfully')
    else
      @enrollment_tracking.destroy
      path = params[:family_id] ? report_family_enrolled_program_enrolled_program_trackings_path(@programmable, @enrollment, tracking_id: @enrollment_tracking.tracking.id) : '#'
      redirect_to path, notice: t('.successfully_deleted')
    end
  end

  def report
    @enrollment_trackings = @enrollment.enrollment_trackings.enrollment_trackings_by(@tracking)
  end
end
