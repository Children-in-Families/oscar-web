class CaseConferencesController < AdminController
  load_and_authorize_resource
  include ApplicationHelper

  before_action :autorize_case_conference, only: [:edit, :update, :destroy]
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
    if Date.today >= @client.next_case_conference_date
      @case_conference = @client.case_conferences.new(case_conference_params)
    else
      @case_conference = @client.case_conferences.reload.last
    end
    check_case_conference = CheckDuplicatedCaseConference.new(@case_conference, case_conference_params)
    if check_case_conference.call
      redirect_to [@client, @case_conference], notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @case_conference.update_attributes(case_conference_params)
      redirect_to [@client, @case_conference], notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @case_conference.destroy
      redirect_to client_case_conferences_path(@client), notice: t('.successfully_deleted')
    else
      messages = @case_conference.errors.full_messages.uniq.join('\n')
      redirect_to [@client, @case_conference], alert: messages
    end
  end

  private

  def autorize_case_conference
    authorize @case_conference
  end

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
