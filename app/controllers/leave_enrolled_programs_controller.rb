class LeaveEnrolledProgramsController < AdminController
  load_and_authorize_resource :LeaveProgram

  include LeaveProgramsConcern
  include FormBuilderAttachments

  before_action :find_entity, :find_enrollment, :find_program_stream
  before_action :find_leave_program, only: [:show, :edit, :update, :destroy]
  before_action :get_attachments, only: [:edit, :update]
  before_action :initial_attachments, only: [:new, :create]
  before_action -> { check_user_permission('editable') }, except: :show
  before_action -> { check_user_permission('readable') }, only: :show

  def new
    redirect_to @entity, alert: "#{@entity.class.name} is already exited from the program." if @entity.try(:accepted?)
  end

  def create
    @cache_key = "#{Apartment::Tenant.current}_cache_#{@entity.class.name.downcase}_id_#{@entity.id}"
    entity_id = Rails.cache.fetch([@cache_key, *leave_program_params.slice(:program_stream_id, :exit_date).values])
    Rails.cache.write([@cache_key, *leave_program_params.slice(:program_stream_id, :exit_date).values], @entity.id, expires_in: 5.seconds)
    if entity_id.nil?
      @leave_program = @enrollment.build_leave_program(leave_program_params)
      if @leave_program.save
        path = find_leave_program_path(@leave_program)
        redirect_to path, notice: t('.successfully_created', entity: params[:family_id] ? t('.family') : params[:community_id] ? t('.community') : t('.client'))
      else
        render :new
      end
    else
      redirect_to @entity, alert: "#{@entity.class.name} is already exited from the program."
    end
  end

  def edit
    check_user_permission('editable')
  end

  def update
    if @leave_program.update_attributes(leave_program_params)
      add_more_attachments(@leave_program)
      if params[:family_id]
        path = family_enrolled_program_leave_enrolled_program_path(@entity, @enrollment, @leave_program)
      elsif params[:community_id]
        path = community_enrolled_program_leave_enrolled_program_path(@entity, @enrollment, @leave_program)
      else
        path = client_client_enrolled_program_leave_enrolled_program_path(@entity, @enrollment, @leave_program)
      end
      redirect_to path, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def show
    check_user_permission('readable')
  end

  def destroy
    name = params[:file_name]
    index = params[:file_index].to_i
    if name.present? && index.present?
      delete_form_builder_attachment(@leave_program, name, index)
    end
    redirect_to request.referer, notice: t('.delete_attachment_successfully')
  end
end
