class MultipleForm::ClientEnrollmentsController < AdminController
  include FormBuilderAttachments
  before_action :find_resources, only: [:new, :create]
  before_action :find_agency, only: [:update, :destroy]

  def new
    @clients = Client.accessible_by(current_ability).active_accepted_status
    @client_enrollment = @program_stream.client_enrollments.new
  end

  def create
    clients = Client.where(id: params['client_enrollment']['client_id'])

    clients.each do |client|
      @client_enrollment = client.client_enrollments.new(client_enrollment_params)
      if @client_enrollment.valid?
        @client_enrollment.save
      else
        break
      end
    end
    unless @client_enrollment.valid?
      @selected_clients = clients.pluck(:id)
      render :new
    else
      if params[:confirm] == 'true'
        redirect_to new_multiple_form_program_stream_client_enrollment_path(@program_stream), notice: t('.successfully_created')
      else
        redirect_to root_path, notice: t('.successfully_created')
      end
    end
  end

  private

  def client_enrollment_params
    params.require(:client_enrollment).permit(:program_stream_id, :enrollment_date, :client_ids)
  end

  def find_resources
   @program_stream = ProgramStream.find_by(id: params[:program_stream_id])
  end

  def find_client_enrollment
    @client_enrollment = @program_stream.client_enrollments.find(params[:id])
  end
end
