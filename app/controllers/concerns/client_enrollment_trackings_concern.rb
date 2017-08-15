module ClientEnrollmentTrackingsConcern
  extend ActiveSupport::Concern

  included do
    before_action :find_client, :find_enrollment, :find_program_stream
    before_action :find_tracking, except: [:index, :show]
    before_action :find_client_enrollment_tracking, only: [:show, :update, :destroy, :edit]
  end

  def client_enrollment_tracking_params
    params.require(:client_enrollment_tracking).permit({}).merge(properties: params[:client_enrollment_tracking][:properties], tracking_id: params[:tracking_id])
  end

  private

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find params[:client_id]
  end

  def find_enrollment
    emrollment_id = params[:client_enrollment_id] || params[:client_enrolled_program_id]
    @enrollment = @client.client_enrollments.find emrollment_id
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
end
