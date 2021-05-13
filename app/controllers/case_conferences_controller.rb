class CaseConferencesController < AdminController
  load_and_authorize_resource
  include ApplicationHelper

  before_action :find_client, :find_case_conference

  def index
    @case_conferences = @client.case_conferences
  end

  def show
  end

  def new
    @prev_case_conference = @client.case_conferences.last
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

  def edit
  end

  def update
    authorize @case_conference
    if @case_conference.update_attributes(case_conference_params)
      redirect_to [@client, @case_conference], notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy

  end

  private

  def find_case_conference
    @case_conference = CaseConference.find(params[:id]) if params[:id]
  end

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id]) if params[:client_id]
  end

  def case_conference_params
    params.require(:case_conference).permit(
      :meeting_date, :client_strength, :client_limitation,
      :client_engagement, :local_resource, user_ids: [], attachments: [],
      case_conference_domains_attributes: [:id, :domain_id, :presenting_problem]
    )
  end
end
