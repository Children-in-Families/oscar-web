class ClientBooksController < AdminController
  include ClientEnrollmentConcern

  before_action :find_client

  def index
    @case_notes  = @client.case_notes.most_recents
    @tasks       = @client.tasks.includes(:client, :domain)
    @assessments = AssessmentDecorator.decorate_collection(@client.assessments.order(created_at: :desc))
    @client_enrollments = program_stream_order_by_enrollment
    @case_histories = case_history
    @custom_field_properties = @client.custom_field_properties
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

    def case_history
      enter_ngos = @client.enter_ngos
      exit_ngos  = @client.exit_ngos
      cps_enrollments = @client.client_enrollments.map(&:attributes)
      cps_leave_programs = LeaveProgram.joins(:client_enrollment).where("client_enrollments.client_id = ?", @client.id)
      referrals = @client.referrals
      case_histories = (enter_ngos + exit_ngos + cps_enrollments + cps_leave_programs + referrals)
    end

    def custom_field_property
      @custom_formable = Client.includes(custom_field_properties: [:custom_field]).accessible_by(current_ability).friendly.find(params[:client_id])
      @custom_field = CustomField.find_by(entity_type: @custom_formable.class.name, id: params[:custom_field_id])
      @custom_field_properties = @custom_formable.custom_field_properties.accessible_by(current_ability).by_custom_field(@custom_field).most_recents
    end
end
