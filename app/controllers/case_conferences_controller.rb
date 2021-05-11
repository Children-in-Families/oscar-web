class CaseConferencesController < AdminController
  include ApplicationHelper

  before_filter :find_client

  def index
    @case_conferences = @client.case_conferences
  end

  def show
  end

  def new
    @case_conference = @client.case_conferences.new
    @case_conference.populate_presenting_problems
  end

  def create
    @case_conference = @client.case_conferences.new(case_conference_params)
    if @case_conference.save
      redirect_to [@client, @case_conference], notice: t('.successfully_created')
    else
      render :new
    end
  end

  private

  def find_model
    @case_conference = CaseConference.find(params[:id]) if params[:id]
  end

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id]) if params[:client_id]
  end

  def case_conference_params
    params.require(:case_conference).permit(
      :case_conference_date, :client_strength, :client_limitation,
      :client_engagement, :local_resource, attachments: [], user_ids: [],
      case_conference_domains_attributes: [:id, :domain_id, :presenting_problem]
    )
  end
end
