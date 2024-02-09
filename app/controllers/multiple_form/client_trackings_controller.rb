class MultipleForm::ClientTrackingsController < AdminController
  include FormBuilderAttachments
  before_action :find_resources, only: [:new, :create]

  def new
    client_ids = @program_stream.client_enrollments.active.pluck(:client_id).uniq
    @clients = Client.accessible_by(current_ability).where(id: client_ids).active_accepted_status
    @client_enrollment_tracking = ClientEnrollmentTracking.new(tracking: @tracking)
    authorize @client_enrollment_tracking, :new?
  end

  def create
    clients = Client.where(slug: params['client_enrollment_tracking']['clients'])

    clients.each do |client|
      client_enrollment = client.client_enrollments.active.find_by(program_stream_id: @program_stream.id)
      @client_enrollment_tracking = client_enrollment.client_enrollment_trackings.new(client_enrollment_tracking_params)
      if @client_enrollment_tracking.valid?
        @client_enrollment_tracking.save
      else
        break
      end
    end
    unless @client_enrollment_tracking.valid?
      client_ids = @program_stream.client_enrollments.active.pluck(:client_id)
      @clients = Client.accessible_by(current_ability).where(id: client_ids).active_accepted_status
      @selectd_clients = clients.pluck(:slug)
      render :new
    else
      if params[:confirm] == 'true'
        redirect_to new_multiple_form_tracking_client_tracking_path(@tracking), notice: t('.successfully_created')
      else
        redirect_to root_path, notice: t('.successfully_created')
      end
    end
  end

  private

  def client_enrollment_tracking_params
    if properties_params.present?
      mappings = {}
      properties_params.each do |k, v|
        mappings[k] = k.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('%22', '"')
      end
      formatted_params = properties_params.map { |k, v| [mappings[k], v] }.to_h
      formatted_params.values.map { |v| v.delete('') if (v.is_a? Array) && v.size > 1 }
    end
    default_params = params.require(:client_enrollment_tracking).permit({}).merge!(tracking_id: params[:tracking_id])
    default_params = default_params.merge!(properties: formatted_params) if formatted_params.present?
    default_params = default_params.merge!(form_builder_attachments_attributes: params[:client_enrollment_tracking][:form_builder_attachments_attributes]) if attachment_params.present?
    default_params
  end

  def find_resources
    tracking = Tracking.find(params[:tracking_id])
    program_stream_ids = ClientEnrollment.active.pluck(:program_stream_id).uniq
    @tracking = Tracking.where(program_stream_id: program_stream_ids).find(params[:tracking_id])
    @program_stream = @tracking.program_stream
  end
end
