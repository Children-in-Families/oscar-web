class ServiceReceivesController < AdminController
  include CaseNoteConcern
  before_action :find_client_service_receive
  # skip_before_action :verify_authenticity_token, only: :create

  def index
    @tasks = @client.tasks.joins(:service_deliveries).select('DISTINCT ON (tasks.id, service_deliveries.id) tasks.id, completion_date, service_deliveries.name, (SELECT name from service_deliveries as sd where sd.id = service_deliveries.parent_id) as category, tasks.completed_by_id')
  end

  def new
    if @current_setting.disabled_add_service_received && !current_user.admin?
      redirect_to client_service_receives_path(@client), alert: t('unauthorized.default')
    end
    @case_note = @client.case_notes.new
    @case_note.populate_notes(nil, 'false')
    fetch_domain_group
  end

  def create
    if params[:domain_groups_attributes].dig(:tasks).blank?
      redirect_to new_client_service_receife_path(@client), alert: 'No task created.'
    else
      params[:domain_groups_attributes][:tasks].each do |task|
        attr = JSON.parse(task)
        task = Task.new(attr.merge({completed: true, completed_by_id: current_user.id}))
        task.save!
        task.reload
        task.update_columns(client_id: @client.id)
        task.create_service_delivery_tasks(attr['service_delivery_ids']) if attr['service_delivery_ids'] && attr['service_delivery_ids'].reject(&:blank?).present?
      end
      redirect_to client_service_receives_path(@client), notice: 'Successfully created'
    end
  end

  private

  def find_client_service_receive
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end
end
