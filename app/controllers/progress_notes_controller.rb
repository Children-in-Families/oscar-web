# class ProgressNotesController < AdminController
#   load_and_authorize_resource
#
#   before_action :find_client
#   before_action :find_progress_note, only: [:show, :edit, :update, :destroy]
#   before_action :find_association, only: [:edit, :update]
#
#   def index
#     @progress_note_grid = ProgressNoteGrid.new(params.fetch(:progress_note_grid, {}).merge!(current_client: @client))
#     respond_to do |f|
#       f.html do
#         @progress_note_grid.scope { |scope| scope.where(client_id: @client.id).page(params[:page]).per(20) }
#       end
#       f.xls do
#         @progress_note_grid.scope { |scope| scope.where(client_id: @client.id) }
#         send_data @progress_note_grid.to_xls, filename: "progress_note_report-#{Time.now}.xls"
#       end
#     end
#   end
#
#   def show
#   end
#
#   def edit
#   end
#
#   def update
#     if @progress_note.update_attributes(progress_note_params)
#       if params[:attachments].present?
#         @progress_note.save_attachment(params)
#         render json: { progress_note: @progress_note, text: t('.successfully_updated'), slug_id: @progress_note.client_slug_id }, status: 200
#       else
#         redirect_to client_progress_note_path(@client, @progress_note), notice: t('.successfully_updated')
#       end
#     else
#       render :edit
#     end
#   end
#
#   def destroy
#     @progress_note.destroy
#     redirect_to client_progress_notes_url, notice: t('.successfully_deleted')
#   end
#
#   def version
#     page = params[:per_page] || 20
#     @progress_note = @client.progress_notes.find(params[:progress_note_id])
#     @versions      = @progress_note.versions.reorder(created_at: :desc).page(params[:page]).per(page)
#   end
#
#   private
#
#   def find_client
#     @client = Client.able.accessible_by(current_ability).friendly.find(params[:client_id])
#   end
#
#   def find_progress_note
#     @progress_note = @client.progress_notes.find(params[:id]).decorate
#   end
#
#   def find_association
#     @assessment_domains  = @client.assessments.last.assessment_domains if @client.assessments.any?
#     @progress_note_types = ProgressNoteType.order(:note_type)
#     @locations           = Location.order('order_option, name')
#     @interventions       = Intervention.order(:action)
#     @materials           = Material.order(:status)
#     @case_workers        = @client.users.order(:first_name, :last_name)
#   end
#
#   def progress_note_params
#     params.require(:progress_note).permit(:date, :user_id, :progress_note_type_id, :location_id, :other_location, :material_id, :response, :additional_note, intervention_ids: [], assessment_domain_ids: [])
#   end
# end
