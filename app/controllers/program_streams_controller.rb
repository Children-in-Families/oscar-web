class ProgramStreamsController < AdminController
  load_and_authorize_resource

  before_action :find_program_stream, except: [:index, :new, :create, :preview]
  before_action :find_ngo
  before_action :authorize_program, only: [:edit, :update, :destroy]
  before_action :find_another_ngo_program_stream, if: -> { @ngo_name.present? }

  def index
    @program_streams = ProgramStream.ordered_by(column_order).page(params[:page_1]).per(20)
    @ngos_program_streams = Kaminari.paginate_array(all_ngos_ordered).page(params[:page_2]).per(20)
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
  end

  def create
    @program_stream = ProgramStream.new(program_stream_params)
    begin
      if @program_stream.save
        redirect_to program_streams_path, notice: t('.successfully_created')
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
        redirect_to program_streams_path, notice: t('.successfully_updated')
      else
        render :edit
      end
    rescue ActiveRecord::RecordNotDestroyed => e
      flash[:alert] = t('.alert')
      render :edit
    end
  end

  def destroy
    if @program_stream.destroy
      redirect_to program_streams_path, notice: t('.successfully_deleted')
    else
      redirect_to program_streams_path, alert: t('.alert')
    end
  end

  def preview
    @program_stream = @another_program_stream
    render :show
  end

  private

  def find_program_stream
    @program_stream = ProgramStream.find(params[:id])
  end

  def program_stream_params
    ngo_name = current_organization.full_name
    params.require(:program_stream).permit(:name, :rules, :description, :enrollment, :tracking, :exit_program, :quantity, trackings_attributes: [:frequency, :time_of_frequency, :fields, :_destroy, :name, :id], domain_ids: []).merge(ngo_name: ngo_name)
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
    Organization.switch_to current_ngo_short_name
    @another_program_stream = program_stream
  end

  def program_streams_all_organizations
    current_org_name = current_organization.short_name
    program_streams = []
    Organization.without_demo.each do |org|
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
    if params[:tab] == 'current'
      column = params[:order]
      sort_by = params[:descending] == 'true' ? 'desc' : 'asc'
      "#{column} #{sort_by}"
    else
      'name'
    end
  end

  def all_ngos_ordered
    if params[:tab] == 'all_ngo'
      column = params[:order]
      ordered = program_streams_all_organizations.sort_by{ |p| p.send(column).to_s.downcase }
      params[:descending] == 'true' ? ordered.reverse : ordered
    else
      program_streams_all_organizations.sort_by(&:name)
    end
  end
end
