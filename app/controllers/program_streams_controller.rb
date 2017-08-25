class ProgramStreamsController < AdminController
  load_and_authorize_resource

  before_action :find_program_stream, except: [:index, :new, :create, :preview]
  before_action :find_ngo
  before_action :authorize_program, only: [:edit, :update, :destroy]
  before_action :complete_program_steam, only: [:new, :create, :edit, :update]
  before_action :find_another_ngo_program_stream, if: -> { @ngo_name.present? }

  def index
    @program_streams = paginate_collection(decorate_programs(column_order)).page(params[:page_1]).per(20)
    @ngos_program_streams = paginate_collection(decorate_programs(all_ngos_ordered)).page(params[:page_2]).per(20)
  end

  def new
    if @ngo_name.present?
      set_attributes
      @program_stream = ProgramStream.new(@another_program_stream.attributes)
      @tracking = @another_program_stream.trackings
    else
      @program_stream = ProgramStream.new
      @tracking = @program_stream.trackings.build
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
      if @program_stream.save
        redirect_to program_stream_path(@program_stream), notice: t('.successfully_created')
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
        redirect_to program_stream_path(@program_stream), notice: t('.successfully_updated')
      else
        render :edit
      end
    rescue ActiveRecord::RecordNotDestroyed => e
      flash[:alert] = t('.alert')
      render :edit
    end
  end

  def destroy
    @program_stream.destroy
    redirect_to program_streams_path, notice: t('.successfully_deleted')
  end

  def preview
    @program_stream = @another_program_stream.decorate
    render :show
  end

  private

  def find_program_stream
    @program_stream = ProgramStream.find(params[:id])
  end

  def program_stream_params
    ngo_name = current_organization.full_name
    delete_select_option_empty

    default_params = [:name, :rules, :description, :enrollment, :exit_program, :tracking_required, :quantity, program_exclusive: [], mutual_dependence: [], domain_ids: []]
    default_params << { trackings_attributes: [:name, :frequency, :time_of_frequency, :fields, :_destroy, :id] } unless program_without_tracking?

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
    program_exclusive = ProgramStream.filter(program_stream.program_exclusive)
    mutual_dependence = ProgramStream.filter(program_stream.mutual_dependence)

    Organization.switch_to current_ngo_short_name
    @another_program_stream = program_stream
    @program_exclusive = program_exclusive
    @mutual_dependence = mutual_dependence
  end

  def program_streams_all_organizations
    current_org_name = current_organization.short_name
    program_streams = []
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      program_streams << ProgramStream.all.reload
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
    (order_string = "#{column} #{sort_by}") if column.present?

    ProgramStream.ordered_by(order_string)
  end

  def all_ngos_ordered
    programs = program_streams_all_organizations.sort_by(&:name)
    column = params[:order]
    return programs unless params[:tab] == 'all_ngo' && column

    ordered = program_streams_all_organizations.sort_by{ |p| p.send(column).to_s.downcase }
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
    @complete_program_steam = ProgramStream.where.not(id: @program_stream).complete.ordered
  end
end
