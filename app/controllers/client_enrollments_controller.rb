class ClientEnrollmentsController < AdminController
  load_and_authorize_resource

  before_action :find_client
  before_action :find_program_stream, except: :index
  before_action :find_client_enrollment, only: [:show, :edit, :update]

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
    @attachment = @client_enrollment.form_builder_attachments.build
  end

  def edit
    authorize @client_enrollment
  end

  def update
    authorize @client_enrollment
    if @client_enrollment.update_attributes(client_enrollment_params)
      add_more_attachments
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
    @client_enrollment.destroy
    redirect_to report_client_client_enrollments_path(@client, program_stream_id: @program_stream, program_streams: params[:program_streams]), notice: t('.successfully_deleted')
  end

  def report
    @enrollments = @program_stream.client_enrollments.where(client_id: @client).order(created_at: :DESC)
  end

  private

  def client_enrollment_params
    default_params = params.require(:client_enrollment).permit(:enrollment_date).merge!(properties: params[:client_enrollment][:properties], program_stream_id: params[:program_stream_id])
    default_params.merge!(form_builder_attachments_attributes: params[:client_enrollment][:form_builder_attachments_attributes]) if action_name == 'create'
    default_params
    # params[:client_enrollment][:properties].keys.each do |k|
    #   params[:client_enrollment][:properties][k].delete('') if params[:client_enrollment][:properties][k].class == Array && params[:client_enrollment][:properties][k].count > 1
    # end
    # attachtmens = params[:client_enrollment][:form_builder_attachments]
    # params.require(:client_enrollment).permit(:enrollment_date, {}).merge(properties: params[:client_enrollment][:properties], program_stream_id: params[:program_stream_id])
  end

  def find_client_enrollment
    @client_enrollment = @client.client_enrollments.find(params[:id])
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

  def add_more_attachments
    return unless attachment_params.present?
    attachment_params.each do |_k, attachment|
      name = attachment['name']
      if name.present? && attachment['file'].present?
        form_builder_attachment = @client_enrollment.form_builder_attachments.file_by_name(name)
        modify_files = form_builder_attachment.file
        modify_files += attachment['file']

        form_builder_attachment = @client_enrollment.form_builder_attachments.find_by(name: name)
        form_builder_attachment.file = modify_files
        form_builder_attachment.save
      end
    end
  end

  def remove_attachment_at_index(index)
    remain_attachment = @custom_field_property.attachments
    deleted_attachment = remain_attachment.delete_at(index)
    deleted_attachment.try(:remove!)
    remain_attachment.empty? ? @custom_field_property.remove_attachments! : (@custom_field_property.attachments = remain_attachment )
  end

  def attachment_params
    params[:client_enrollment][:form_builder_attachments_attributes]
  end
end
