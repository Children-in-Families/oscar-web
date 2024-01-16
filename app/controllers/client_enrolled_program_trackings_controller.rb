class ClientEnrolledProgramTrackingsController < AdminController
  load_and_authorize_resource :ClientEnrollmentTracking

  include ClientEnrollmentTrackingsConcern
  include FormBuilderAttachments

  before_action :find_client, :find_enrollment, :find_program_stream
  before_action :find_tracking, except: [:index, :show, :destroy]
  before_action :find_client_enrollment_tracking, only: [:update, :destroy, :edit, :show]
  before_action :get_attachments, only: [:new, :create, :edit, :update]
  before_action -> { check_user_permission('editable') }, except: [:index, :show, :report]
  before_action -> { check_user_permission('readable') }, only: :show

  def index
    @tracking_grid = ClientEnrolledProgramTrackingGrid.new(params[:tracking_grid])
    @tracking_grid.scope { |scope| scope.visible.where(program_stream_id: @program_stream).page(params[:page]).per(20) }
  end

  def new
    @client_enrollment_tracking = @enrollment.client_enrollment_trackings.new(tracking_id: @tracking.id)
    @attachment = @client_enrollment_tracking.form_builder_attachments.build
    authorize @client_enrollment_tracking
  end

  def create
    @client_enrollment_tracking = @enrollment.client_enrollment_trackings.new(client_enrollment_tracking_params)
    authorize @client_enrollment_tracking

    if @client_enrollment_tracking.save
      redirect_to report_client_client_enrolled_program_client_enrolled_program_trackings_path(@client, @enrollment, tracking_id: @tracking.id), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
    authorize @client_enrollment_tracking
  end

  def update
    authorize @client_enrollment_tracking
    if @client_enrollment_tracking.update_attributes(client_enrollment_tracking_params)
      add_more_attachments(@client_enrollment_tracking)
      redirect_to report_client_client_enrolled_program_client_enrolled_program_trackings_path(@client, @enrollment, tracking_id: @tracking.id), notice: t('.successfully_updated')
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

    notice = ''
    if name.present? && index.present?
      delete_form_builder_attachment(@client_enrollment_tracking, name, index)
      redirect_to request.referer, notice: t('.delete_attachment_successfully')
    else
      @client_enrollment_tracking.destroy
      redirect_to report_client_client_enrolled_program_client_enrolled_program_trackings_path(@client, @enrollment, tracking_id: @client_enrollment_tracking.tracking.id), notice: t('.successfully_deleted')
    end
  end

  def report
    @client_enrollment_trackings = @enrollment.client_enrollment_trackings.enrollment_trackings_by(@tracking)
  end
end
