class ClientBooksController < AdminController
  before_action :find_client

  def index
    @case_notes  = @client.case_notes.most_recents
    @tasks       = @client.tasks.order(created_at: :desc)
    @assessments = AssessmentDecorator.decorate_collection(@client.assessments.order(created_at: :desc))
  end

  private
    def find_client
      @client = Client.includes(custom_field_properties: [:custom_field], client_enrollments: [:program_stream]).accessible_by(current_ability).friendly.find(params[:client_id]).decorate
    end
end
