class ClientEnrollmentsController < AdminController
  load_and_authorize_resource

  include FormBuilderAttachments

  before_action :find_client
  before_action :find_program_stream, except: :index
  before_action :find_client_enrollment, only: [:show, :edit, :update, :destroy]
  before_action :get_attachments, only: [:new, :edit, :update, :create]

  def index
    program_streams = ProgramStreamDecorator.decorate_collection(ordered_program)
    @program_streams = Kaminari.paginate_array(program_streams).page(params[:page]).per(20)
  end

  def new
    if @program_stream.rules.present?
      if @program_stream.program_exclusive.any? || @program_stream.mutual_dependence.any?
        redirect_to client_client_enrollments_path(@client, program_streams: params[:program_streams]), alert: t('.client_not_valid') unless valid_client? && valid_program?
      else
        redirect_to client_client_enrollments_path(@client, program_streams: params[:program_streams]), alert: t('.client_not_valid') unless valid_client?
      end
    elsif @program_stream.mutual_dependence.any? || @program_stream.program_exclusive.any?
      redirect_to client_client_enrollments_path(@client, program_streams: params[:program_streams]), alert: t('.client_not_valid') unless valid_program?
    end
    @client_enrollment = @client.client_enrollments.new(program_stream_id: @program_stream)
  end

  def edit
    authorize @client_enrollment
  end

  def update
    authorize @client_enrollment
    if @client_enrollment.update_attributes(client_enrollment_params)
      add_more_attachments(@client_enrollment)
      redirect_to client_client_enrollment_path(@client, @client_enrollment, program_stream_id: @program_stream, program_streams: params[:program_streams]), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def show
  end

  def create
    @client_enrollment = @client.client_enrollments.new(client_enrollment_params)
    authorize @client_enrollment
    if @client_enrollment.save
      redirect_to client_client_enrollment_path(@client, @client_enrollment, program_stream_id: @program_stream, program_streams: 'enrolled-program-streams'), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def destroy
    name = params[:file_name]
    index = params[:file_index].to_i
    params_program_streams = params[:program_streams]
    if name.present? && index.present?
      delete_form_builder_attachment(@client_enrollment, name, index)
    end
    redirect_to request.referer, notice: t('.delete_attachment_successfully')
    # @client_enrollment.destroy
    # redirect_to report_client_client_enrollments_path(@client, program_stream_id: @program_stream, program_streams: params[:program_streams]), notice: t('.successfully_deleted')
  end

  def report
    @enrollments = @program_stream.client_enrollments.where(client_id: @client).order(created_at: :DESC)
  end

  private

  def client_enrollment_params
    (properties_params.values.map{ |v| v.delete('') if (v.is_a?Array) && v.size > 1 }) if properties_params.present?

    default_params = params.require(:client_enrollment).permit(:enrollment_date).merge!(program_stream_id: params[:program_stream_id])
    default_params = default_params.merge!(properties: params[:client_enrollment][:properties]) if properties_params.present?
    default_params = default_params.merge!(form_builder_attachments_attributes: params[:client_enrollment][:form_builder_attachments_attributes]) if action_name == 'create' && attachment_params.present?
    default_params

  end

  def find_client_enrollment
    @client_enrollment = @client.client_enrollments.find(params[:id])
  end

  def get_attachments
    @attachments = @client_enrollment.form_builder_attachments
  end

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def find_program_stream
    @program_stream = ProgramStream.find(params[:program_stream_id])
  end

  def client_filtered
    AdvancedSearches::ClientAdvancedSearch.new(@program_stream.rules, Client.all).filter
  end

  def program_stream_order_by_enrollment
    program_streams = []
    if params[:program_streams] == 'enrolled-program-streams'
      client_enrollments_active = ProgramStream.active_enrollments(@client).complete
      program_streams           = client_enrollments_active
    elsif params[:program_streams] == 'program-streams'
      client_enrollments_exited     = ProgramStream.inactive_enrollments(@client).complete
      client_enrollments_inactive   = ProgramStream.without_status_by(@client).complete
      program_streams               = client_enrollments_exited + client_enrollments_inactive
    end
    program_streams
  end

  def ordered_program
    column = params[:order]
    descending = params[:descending] == 'true'
    if column.present? && column != 'status'
      ordered = program_stream_order_by_enrollment.sort_by{ |ps| ps.send(column).to_s.downcase }
      descending ? ordered.reverse : ordered
    elsif column.present? && column == 'status'
      descending ? program_stream_order_by_enrollment.reverse : program_stream_order_by_enrollment
    else
      program_stream_order_by_enrollment
    end
  end

  def valid_client?
    client_filtered.ids.include? @client.id
  end

  def valid_program?
    program_active_status_ids   = ProgramStream.active_enrollments(@client).pluck(:id)
    if @program_stream.program_exclusive.any? && @program_stream.mutual_dependence.any?
      (@program_stream.program_exclusive & program_active_status_ids).empty? && (@program_stream.mutual_dependence - program_active_status_ids).empty?
    elsif @program_stream.mutual_dependence.any?
      (@program_stream.mutual_dependence - program_active_status_ids).empty?
    elsif @program_stream.program_exclusive.any?
      (@program_stream.program_exclusive & program_active_status_ids).empty?
    end
  end
end
