module LeaveProgramsConcern
  extend ActiveSupport::Concern

  included do
    before_action :find_client, :find_enrollment, :find_program_stream
    before_action :find_leave_program, only: [:show, :edit, :update, :destroy]
  end

  def leave_program_params
    params[:leave_program][:properties].values.map{|v| v.delete('')}
    params.require(:leave_program).permit(:exit_date, {}).merge(properties: params[:leave_program][:properties], program_stream_id: params[:program_stream_id])
  end

  private

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find params[:client_id]
  end

  def find_enrollment
    enrollment_id = params[:client_enrollment_id] || params[:client_enrolled_program_id]
    @enrollment = @client.client_enrollments.find enrollment_id
  end

  def find_program_stream
    @program_stream = @enrollment.program_stream
  end

  def find_leave_program
    @leave_program = @enrollment.leave_program
  end
end
