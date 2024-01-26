class ProgramStreamsController < AdminController
  load_and_authorize_resource

  before_action :find_program_stream, except: [:index, :new, :create, :preview, :search]
  before_action :find_ngo
  before_action :authorize_program, only: [:edit, :update, :destroy]
  before_action :find_another_ngo_program_stream, if: -> { @ngo_name.present? }
  before_action :remove_html_tags, only: [:create, :update]
  before_action :fetch_domains, :find_entity_type, only: [:new, :create, :edit, :update]
  before_action :available_exclusive_programs, :available_mutual_dependence_programs, only: [:edit, :update]
  before_action :complete_program_steam, only: [:new, :create]

  def index
    @program_streams = paginate_collection(decorate_programs(column_order)).page(params[:page_1]).per(20)
    @ngos_program_streams = paginate_collection(program_stream_ordered).page(params[:page_2]).per(20)
    @demo_program_streams = paginate_collection(decorate_programs(program_stream_ordered('demo'))).page(params[:page_3]).per(20) unless current_organization.short_name == 'demo'
  end

  def new
    if @ngo_name.present?
      set_attributes
      @program_stream = ProgramStream.new(@another_program_stream.attributes)
      @tracking = @another_program_stream.trackings
    else
      copy_form_from_custom_field
    end
  end

  def edit
    redirect_to program_streams_path, alert: t('unauthorized.default') if @ngo_name.present? && @ngo_name != current_organization.full_name
  end

  def show
    @program_exclusive = ProgramStream.filter(@program_stream.program_exclusive)
    @mutual_dependence = ProgramStream.filter(@program_stream.mutual_dependence)
    @program_stream = @program_stream.decorate
  end

  def create
    @program_stream = ProgramStream.new(program_stream_params)
    begin
      if program_stream_params[:domain_ids].reject(&:blank?).present? ? @program_stream.save(validate: false) : @program_stream.save
        redirect_to program_stream_path(@program_stream, entity_type: @program_stream.entity_type), notice: t('.successfully_created')
      else
        render :new
      end
    rescue ActiveRecord::RecordNotUnique => e
      flash[:alert] = t('.alert')
      render :new
    end
  end

  def update
    begin
      if @program_stream.update_attributes(program_stream_params)
        redirect_to program_stream_path(@program_stream, entity_type: @program_stream.entity_type), notice: t('.successfully_updated')
      else
        render :edit
      end
    rescue ActiveRecord::RecordNotDestroyed => e
      flash[:alert] = t('.alert')
      render :edit
    end
  end

  def destroy
    if @program_stream.client_enrollments.with_deleted.size.positive?
      @program_stream.destroy
    else
      @program_stream.destroy_fully!
    end
    redirect_to program_streams_path, notice: t('.successfully_deleted')
  end

  def preview
    @program_stream = @another_program_stream.decorate
    render :show
  end

  def search
    @program_streams = paginate_collection(decorate_programs(search_program_streams)).page(params[:page]).per(20)
    redirect_to program_streams_path, alert: t('.no_results') if @program_streams.empty?
  end

  private

  def find_program_stream
    @program_stream = ProgramStream.find(params[:id])
  end

  def remove_html_tags
    enrollment = params[:program_stream][:enrollment]
    params[:program_stream][:enrollment] = strip_tags(enrollment)

    exit_program = params[:program_stream][:exit_program]
    params[:program_stream][:exit_program] = strip_tags(exit_program)

    trackings = params[:program_stream][:trackings_attributes]
    if trackings.present?
      trackings.values.each do |value|
        value['fields'] = strip_tags(value['fields'])
      end
    end
  end

  def strip_tags(value)
    ActionController::Base.helpers.strip_tags(value).gsub(/(\\n)|(\\t)/, "")
  end

  def program_stream_params
    ngo_name = current_organization.full_name
    delete_select_option_empty
    default_params = [:entity_type, :name, :rules, :description, :enrollment, :exit_program, :tracking_required, :quantity, program_exclusive: [], mutual_dependence: [], domain_ids: [], service_ids: [], internal_referral_user_ids: []]
    default_params << { trackings_attributes: [:name, :frequency, :time_of_frequency, :fields, :hidden, :_destroy, :id] } unless program_without_tracking?

    params[:program_stream][:service_ids] = params[:program_stream][:service_ids].uniq
    params.require(:program_stream).permit(default_params).merge(ngo_name: ngo_name)
  end

  def program_without_tracking?
    params[:program_stream][:tracking_required].to_i == 1
  end

  def find_ngo
    @ngo_name = params[:ngo_name]
  end

  def find_another_ngo_program_stream
    current_ngo_short_name = current_organization.short_name
    program_stream_id = params[:program_stream_id]
    ngo = Organization.find_by(full_name: @ngo_name)
    Organization.switch_to ngo.short_name
    program_stream = ProgramStream.where(id: program_stream_id).includes(:trackings).first
    program_exclusive = program_stream&.program_exclusive ? ProgramStream.filter(program_stream.program_exclusive) : []
    mutual_dependence = program_stream&.mutual_dependence ? ProgramStream.filter(program_stream.mutual_dependence) : []

    Organization.switch_to current_ngo_short_name
    @another_program_stream = program_stream
    @program_exclusive = program_exclusive
    @mutual_dependence = mutual_dependence
  end

  def find_program_stream_organizations(org = '')
    current_org_name = current_organization.short_name
    organizations = org == 'demo' ? Organization.where(short_name: 'demo') : Organization.oscar.order(:full_name)
    program_streams = organizations.map do |org|
      Organization.switch_to org.short_name
      programs = ProgramStream.includes(:services).all.reload.map do |program_stream|
        OpenStruct.new({ **program_stream.attributes.symbolize_keys, services: program_stream.services, domains: program_stream.domains })
      end
      decorate_programs(programs)
    end
    Organization.switch_to(current_org_name)
    program_streams.flatten
  end

  def set_attributes
    @another_program_stream.id = nil
    @another_program_stream.trackings.map{ |t| t.id = nil, t.program_stream_id=nil }
  end

  def authorize_program
    if @program_stream.present? && @program_stream.ngo_name != current_organization.full_name
      redirect_to program_streams_path, alert: t('unauthorized.default')
    end
  end

  def column_order
    order_string = 'name'
    order_string unless params[:tab] == 'current'

    column = params[:order]
    sort_by = params[:descending] == 'true' ? 'desc' : 'asc'
    column == "quantity" ? "#{column}" : "lower(#{column})"
    (order_string = "#{column} #{sort_by}") if column.present?

    ProgramStream.includes(:services, :client_enrollments).ordered_by(order_string)
  end

  def program_stream_ordered(org = '')
    program_streams = org == 'demo' ? find_program_stream_organizations('demo') : find_program_stream_organizations
    programs = program_streams.sort_by(&:name)
    column = params[:order]
    return programs unless (params[:tab] == 'all_ngo' || params[:tab] == 'demo_ngo') && column

    ordered = program_streams.sort_by{ |p| p.send(column).to_s.downcase }
    programs = (column.present? && params[:descending] == 'true' ? ordered.reverse : ordered)
    programs
  end

  def delete_select_option_empty
    program_exclusive = params[:program_stream][:program_exclusive]
    mutual_dependence = params[:program_stream][:mutual_dependence]
    program_exclusive.delete('') if program_exclusive.present?
    mutual_dependence.delete('') if mutual_dependence.present?
  end

  def decorate_programs(values)
    ProgramStreamDecorator.decorate_collection(values)
  end

  def paginate_collection(values)
    Kaminari.paginate_array(values)
  end

  def complete_program_steam
    @exclusive_programs = @mutual_dependences = ProgramStream.where.not(id: @program_stream).attached_with(@entity_type).complete.ordered
  end

  def search_program_streams
    results = []
    if params[:search].present?
      current_org_name = current_organization.short_name
      name   = params[:search]
      Organization.all.each do |org|
        Organization.switch_to(org.short_name)
          program_streams = ProgramStream.by_name(name)
          results << program_streams if program_streams.present?
      end
      Organization.switch_to(current_org_name)
    end
    results.flatten.sort! {|x, y| x.name.downcase <=> y.name.downcase}
  end

  def copy_form_from_custom_field
    if params[:custom_field_id].present?
      custom_field = CustomField.find(params[:custom_field_id])
      if params[:field] == 'enrollment'
        @program_stream = ProgramStream.new(enrollment: custom_field.fields)
        @tracking = @program_stream.trackings.build
      elsif params[:field] == 'tracking'
        @program_stream = ProgramStream.new
        @tracking = @program_stream.trackings.build(fields: custom_field.fields)
      elsif params[:field] == 'exit_program'
        @program_stream = ProgramStream.new(exit_program: custom_field.fields)
        @tracking = @program_stream.trackings.build
      end
    else
      @program_stream = ProgramStream.new
      @tracking = @program_stream.trackings.build
    end
  end

  def available_exclusive_programs
    if @entity_type == 'Client'
      client_ids = @program_stream.client_enrollments.active.pluck(:client_id).uniq
      active_program_ids = ClientEnrollment.active.where(client_id: client_ids).pluck(:program_stream_id)
    else
      entity_ids = @program_stream.enrollments.active.pluck(:programmable_id).uniq
      active_program_ids = Enrollment.active.where(programmable_id: entity_ids).pluck(:program_stream_id)
    end
    available_programs_for_exclusive = ProgramStream.where.not(id: active_program_ids).attached_with(@entity_type).complete.ordered
    @exclusive_programs = available_programs_for_exclusive
  end

  def available_mutual_dependence_programs
    all_programs = ProgramStream.where.not(id: @program_stream).attached_with(@entity_type).complete.ordered
    if @entity_type == 'Client'
      active_entity_ids   = @program_stream.client_enrollments.active.pluck(:client_id).uniq
      active_program_ids  = ClientEnrollment.active.where(client_id: active_entity_ids).pluck(:program_stream_id)
    else
      active_entity_ids   = @program_stream.enrollments.active.pluck(:programmable_id).uniq
      active_program_ids  = Enrollment.active.where(programmable_id: active_entity_ids).pluck(:program_stream_id)
    end
    mutuals_available   = ProgramStream.filter(active_program_ids).where.not(id: @program_stream.id).attached_with(@entity_type).complete.ordered
    @mutual_dependences = active_entity_ids.any? ? mutuals_available : all_programs
  end

  def fetch_domains
    @csi_domains = Domain.csi_domains
  end

  def find_entity_type
    @entity_type = params['entity_type'] || params[:program_stream][:entity_type]
  end
end
