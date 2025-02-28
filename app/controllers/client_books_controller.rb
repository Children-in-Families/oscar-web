class ClientBooksController < AdminController
  include ClientEnrollmentConcern

  before_action :find_client

  def index
    @calls = @client.calls.distinct
    @case_notes = @client.case_notes.most_recents.includes(:domain_groups, custom_field_property: :custom_field)
    @assessments = AssessmentDecorator.decorate_collection(@client.assessments.includes(:care_plan, :custom_assessment_setting).order(created_at: :desc))
    @client_enrollments = program_stream_order_by_enrollment[:enrollments].compact
    @client_enrollment_trackings = program_stream_order_by_enrollment[:enrollment_trackings].flatten.compact
    @client_enrollment_leave_programs = program_stream_order_by_enrollment[:enrollment_leave_programs].compact
    @custom_field_properties = @client.custom_field_properties
  end

  private

  def find_client
    @client = Client.includes(:calls, custom_field_properties: [:custom_field], client_enrollments: [:program_stream]).accessible_by(current_ability).friendly.find(params[:client_id]).decorate
  end

  def program_stream_order_by_enrollment
    results = {
      enrollments: [], enrollment_trackings: [], enrollment_leave_programs: []
    }
    enrollments = @client.client_enrollments.includes(:leave_program)
    enrollments.each do |enrollment|
      results[:enrollments] << enrollment
      results[:enrollment_trackings] << enrollment.client_enrollment_trackings.includes(:tracking)
      results[:enrollment_leave_programs] << enrollment.leave_program
    end
    results
  end

  def case_history
    cps_enrollments = @client.client_enrollments.map(&:attributes)
    cps_leave_programs = LeaveProgram.joins(:client_enrollment).distinct.where('client_enrollments.client_id = ?', @client.id)
    # referrals = @client.referrals
    case_histories = (cps_enrollments + cps_leave_programs).flatten.uniq
  end

  def custom_field_property
    @custom_formable = Client.includes(custom_field_properties: [:custom_field]).accessible_by(current_ability).friendly.find(params[:client_id])
    @custom_field = CustomField.find_by(entity_type: @custom_formable.class.name, id: params[:custom_field_id])
    @custom_field_properties = @custom_formable.custom_field_properties.accessible_by(current_ability).by_custom_field(@custom_field).most_recents
  end
end
