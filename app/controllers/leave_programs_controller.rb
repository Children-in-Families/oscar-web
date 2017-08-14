class LeaveProgramsController < AdminController
  load_and_authorize_resource

  include FormBuilderAttachments

  before_action :find_client, :find_enrollment, :find_program_stream

  def new
    @leave_program = @enrollment.build_leave_program
    @attachment    = @leave_program.form_builder_attachments.build
  end

  def create
    @leave_program = @enrollment.create_leave_program(leave_program_params)
    if @leave_program.save
      redirect_to client_client_enrollment_leave_program_path(@client, @enrollment, @leave_program, program_streams: params[:program_streams]), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @leave_program.update_attributes(leave_program_params)
      add_more_attachments(@leave_program)
      redirect_to client_client_enrollment_leave_program_path(@client, @enrollment, @leave_program, program_streams: params[:program_streams]), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def show
    @leave_program = @enrollment.leave_program
  end

  private

  def leave_program_params
    (properties_params.values.map{ |v| v.delete('') if (v.is_a?Array) && v.size > 1 }) if properties_params.present?
    default_params = params.require(:leave_program).permit(:exit_date).merge!(program_stream_id: params[:program_stream_id])
    default_params = default_params.merge!(properties: params[:leave_program][:properties]) if properties_params.present?
    default_params = default_params.merge!(form_builder_attachments_attributes: params[:leave_program][:form_builder_attachments_attributes]) if action_name == 'create' && attachment_params.present?
    default_params

    # params.require(:leave_program).permit(:exit_date, {}).merge(properties: params[:leave_program][:properties], program_stream_id: params[:program_stream_id])
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

  def properties_params
    params[:leave_program][:properties]
  end
end
