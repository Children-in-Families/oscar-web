module ClientEnrollmentConcern
  extend ActiveSupport::Concern

  included do
    before_action :find_client
    before_action :find_program_stream, except: :index
    before_action :find_client_enrollment, only: [:show, :edit, :update, :destroy]
  end

  def client_enrollment_params
    params[:client_enrollment][:properties].values.map{|v| v.delete('')}
    params.require(:client_enrollment).permit(:enrollment_date, {}).merge(properties: params[:client_enrollment][:properties], program_stream_id: params[:program_stream_id])
  end

  def client_enrollment_index_path
    redirect_to client_client_enrollments_path(@client), alert: t('.client_not_valid')
  end

  def client_filtered
    AdvancedSearches::ClientAdvancedSearch.new(@program_stream.rules, Client.all).filter
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
    if @program_stream.has_program_exclusive? && @program_stream.has_mutual_dependence?
      (@program_stream.program_exclusive & program_active_status_ids).empty? && (@program_stream.mutual_dependence - program_active_status_ids).empty?
    elsif @program_stream.has_mutual_dependence?
      (@program_stream.mutual_dependence - program_active_status_ids).empty?
    elsif @program_stream.has_program_exclusive?
      (@program_stream.program_exclusive & program_active_status_ids).empty?
    end
  end

  private

  def find_client_enrollment
    @client_enrollment = @client.client_enrollments.find(params[:id])
  end

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def find_program_stream
    @program_stream = ProgramStream.find(params[:program_stream_id])
  end
end
