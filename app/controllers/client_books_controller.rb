class ClientBooksController < AdminController
  include ClientEnrollmentConcern

  before_action :find_client

  def index
    @case_notes  = @client.case_notes.most_recents
    @tasks       = @client.tasks
    @assessments = AssessmentDecorator.decorate_collection(@client.assessments.order(created_at: :desc))
    @client_enrollments = program_stream_order_by_enrollment
  end

  private
    def find_client
      @client = Client.includes(custom_field_properties: [:custom_field], client_enrollments: [:program_stream]).accessible_by(current_ability).friendly.find(params[:client_id]).decorate
    end

    def program_stream_order_by_enrollment
      @enrollments = @client.client_enrollments
      @enrollments.map do |enrollment|
        [enrollment, enrollment.leave_program, enrollment.client_enrollment_trackings]
      end.flatten.compact
    end
end
