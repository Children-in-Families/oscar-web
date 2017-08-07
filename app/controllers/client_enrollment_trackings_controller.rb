class ClientEnrollmentTrackingsController < AdminController
  load_and_authorize_resource

  before_action :find_client, :find_enrollment, :find_program_stream
  before_action :find_tracking, except: [:index]
  before_action :find_client_enrollment_tracking, only: [:show, :update, :destroy]
  before_action :get_attachments, only: [:new, :edit, :update]

  def index
    @tracking_grid = TrackingGrid.new(params[:tracking_grid])
    @tracking_grid.scope { |scope| scope.where(program_stream_id: @program_stream).page(params[:page]).per(20) }
  end

  def new
    @client_enrollment_tracking = @enrollment.client_enrollment_trackings.new
    @attachment                 = @client_enrollment_tracking.form_builder_attachments.build
    authorize @client_enrollment_tracking
  end

  def create
    @client_enrollment_tracking = @enrollment.client_enrollment_trackings.new(client_enrollment_tracking_params)
    authorize @client_enrollment_tracking

    if @client_enrollment_tracking.save
      redirect_to report_client_client_enrollment_client_enrollment_trackings_path(@client, @enrollment, tracking_id: @tracking.id, program_streams: 'enrolled-program-streams'), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
    authorize @client_enrollment_tracking
  end

  def show
  end

  def update
    authorize @client_enrollment_tracking
    if @client_enrollment_tracking.update_attributes(client_enrollment_tracking_params)
      add_more_attachments
      redirect_to report_client_client_enrollment_client_enrollment_trackings_path(@client, @enrollment, tracking_id: @tracking.id, program_streams: 'enrolled-program-streams'), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    name = params[:file_name]
    index = params[:file_index].to_i
    params_program_streams = params[:program_streams]
    notice = ""
    if name.present? && index.present?
      delete_form_builder_attachment(name, index)
      notice = t('.delete_attachment_successfully')
    else
      @client_enrollment_tracking.destroy
      notice = t('.successfully_deleted')
    end
    redirect_to request.referer, notice: notice
  end

  def report
    @client_enrollment_trackings = @enrollment.client_enrollment_trackings.enrollment_trackings_by(@tracking)
  end

  private

  def client_enrollment_tracking_params
    # params.require(:client_enrollment_tracking).permit({}).merge(properties: params[:client_enrollment_tracking][:properties], tracking_id: params[:tracking_id])

    default_params = params.require(:client_enrollment_tracking).permit({}).merge!(tracking_id: params[:tracking_id])
    default_params = default_params.merge!(properties: params[:client_enrollment_tracking][:properties]) if properties_params.present?
    default_params = default_params.merge!(form_builder_attachments_attributes: params[:client_enrollment_tracking][:form_builder_attachments_attributes]) if action_name == 'create' && attachment_params.present?
    default_params
  end

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find params[:client_id]
  end

  def find_enrollment
    @enrollment = @client.client_enrollments.find params[:client_enrollment_id]
  end

  def find_program_stream
    @program_stream = @enrollment.program_stream
  end

  def find_tracking
    @tracking = @program_stream.trackings.find params[:tracking_id]
  end

  def find_client_enrollment_tracking
    @client_enrollment_tracking = @enrollment.client_enrollment_trackings.find params[:id]
  end

  def get_attachments
    @attachments = @client_enrollment_tracking.form_builder_attachments
  end

  def properties_params
    params[:client_enrollment_tracking][:properties]
  end

  def add_more_attachments
    return unless attachment_params.present?
    attachment_params.each do |_k, attachment|
      name = attachment['name']
      if name.present? && attachment['file'].present?
        form_builder_attachment = @client_enrollment_tracking.form_builder_attachments.file_by_name(name)
        modify_files = form_builder_attachment.file
        modify_files += attachment['file']

        form_builder_attachment = @client_enrollment_tracking.form_builder_attachments.find_by(name: name)
        form_builder_attachment.file = modify_files
        form_builder_attachment.save
      end
    end
  end

  def delete_form_builder_attachment(name, index)
    attachment = @client_enrollment_tracking.get_form_builder_attachment(name)
    remain_file  = attachment.file
    deleted_file = remain_file.delete_at(index)
    deleted_file.try(:remove!)
    remain_file.empty? ? attachment.remove_file! : attachment.file = remain_file
    attachment.save
  end

  def attachment_params
    params[:client_enrollment_tracking][:form_builder_attachments_attributes]
  end
end
