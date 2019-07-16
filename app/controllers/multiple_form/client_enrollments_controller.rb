class MultipleForm::ClientEnrollmentsController < AdminController
  load_and_authorize_resource
  include ClientEnrollmentConcern
  include FormBuilderAttachments
  before_action :find_clients, :find_resources, only: [:new, :create]
  before_action :find_agency, only: [:update, :destroy]

  def new
    @clients = find_clients.map do |client|
      if @program_stream.has_rule?
        if @program_stream.has_program_exclusive? || @program_stream.has_mutual_dependence?
          next unless valid_client?(client) && valid_program_program_stream?(client)
        else
          next unless valid_client?(client)
        end
      elsif @program_stream.has_program_exclusive? || @program_stream.has_mutual_dependence?
        next unless valid_program_program_stream?(client)
      end

      client
    end.compact

    @client_enrollment = @program_stream.client_enrollments.new
  end

  def create
    clients = find_clients.where(id: params['client_enrollment']['client_id'])

    clients.each do |client|
      @client_enrollment = client.client_enrollments.new(client_enrollment_params)
        
      if @client_enrollment.valid?
        authorize(client) && authorize(@client_enrollment)
        @client_enrollment.save
      else
        break
      end
    end

    unless @client_enrollment.valid?
      @selected_clients = clients.pluck(:id)
      render :new
    else
      if params[:confirm] == 'true'
        redirect_to new_multiple_form_program_stream_client_enrollment_path(@program_stream), notice: t('.successfully_created')
      else
        redirect_to root_path, notice: t('.successfully_created')
      end
    end
  end

  private

    def client_enrollment_params
      if properties_params.present?
        mappings = {}
        properties_params.each do |k, v|
          mappings[k] = k.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('%22', '"')
        end
        formatted_params = properties_params.map {|k, v| [mappings[k], v] }.to_h
        formatted_params.values.map{ |v| v.delete('') if (v.is_a?Array) && v.size > 1 }
      end
      default_params = params.require(:client_enrollment).permit(:enrollment_date).merge!(program_stream_id: params[:program_stream_id])
      default_params = default_params.merge!(properties: formatted_params) if formatted_params.present?
      default_params = default_params.merge!(form_builder_attachments_attributes: params[:client_enrollment][:form_builder_attachments_attributes]) if attachment_params.present?
      default_params
    end

    def find_clients
      @clients ||= Client.accessible_by(current_ability).active_accepted_status
    end

    def find_resources
     @program_stream = ProgramStream.find_by(id: params[:program_stream_id])
    end

    def valid_program_program_stream?(client)
      program_active_status_ids   = ProgramStream.active_enrollments(client).pluck(:id)
      if @program_stream.has_program_exclusive? && @program_stream.has_mutual_dependence?
        (@program_stream.program_exclusive & program_active_status_ids).empty? && (@program_stream.mutual_dependence - program_active_status_ids).empty?
      elsif @program_stream.has_mutual_dependence?
        (@program_stream.mutual_dependence - program_active_status_ids).empty?
      elsif @program_stream.has_program_exclusive?
        (@program_stream.program_exclusive & program_active_status_ids).empty?
      end
    end
end
