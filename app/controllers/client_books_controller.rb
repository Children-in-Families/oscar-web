class ClientBooksController < AdminController
  include ClientEnrollmentConcern

  before_action :find_client

  def index
    @case_notes  = @client.case_notes.most_recents
    @tasks       = @client.tasks
    @assessments = AssessmentDecorator.decorate_collection(@client.assessments.order(created_at: :desc))
    @program_streams = ordered_program
  end

  private
    def find_client
      @client = Client.includes(custom_field_properties: [:custom_field], client_enrollments: [:program_stream]).accessible_by(current_ability).friendly.find(params[:client_id]).decorate
    end

    def program_stream_order_by_enrollment
      program_streams = []
      if current_user.admin? || current_user.strategic_overviewer?
        all_programs = ProgramStream.all
      else
        all_programs = ProgramStream.where(id: current_user.program_stream_permissions.where(readable: true, user: current_user).pluck(:program_stream_id))
      end

      client_enrollments_exited     = all_programs.inactive_enrollments(@client).complete.select(:id, :name, :created_at)
      client_enrollments_inactive   = all_programs.without_status_by(@client).complete.select(:id, :name, :created_at)

      program_streams               = client_enrollments_exited + client_enrollments_inactive
    end
end
