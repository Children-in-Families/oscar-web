class DomainsController < AdminController
  load_and_authorize_resource

  before_action :find_domain, only: [:edit, :update, :destroy]
  before_action :find_domain_group, except: [:index, :destroy]

  def index
    @domains = Domain.csi_domains.page(params[:page_1]).per(10)
    @custom_domains = Domain.custom_csi_domains.page(params[:page_2]).per(10)
    @results = Domain.csi_domains.count
    @custom_domain_results = Domain.custom_csi_domains.count
  end

  def new
    if params[:copy] != 'true'
      @domain = Domain.new
    else
      @domain     = Domain.find(params[:domain_id])
      domain_attr = @domain.attributes.except('id')
      @domain     = Domain.new(domain_attr)
    end
  end

  def create
    @domain = Domain.new(domain_params)
    @domain.custom_domain = true
    if @domain.save
      redirect_to domains_path(tab: 'custom_domain'), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    # @domain.custom_domain = true
    if @domain.update_attributes(domain_params)
      # redirect_to domains_path(tab: 'custom_domain'), notice: t('.successfully_updated')
      redirect_to domains_path, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @domain.destroy
      redirect_to domains_url, notice: t('.successfully_deleted')
    else
      redirect_to domains_url, alert: t('.alert')
    end
  end

  def version
    page = params[:per_page] || 20
    @domain   = Domain.find(params[:domain_id])
    @versions = @domain.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def domain_params
    params.require(:domain).permit(
      :name, :identity, :description, :local_description, :domain_group_id,
      :score_1_color, :score_2_color, :score_3_color, :score_4_color,
      :score_1_definition, :score_2_definition, :score_3_definition, :score_4_definition,
      :score_1_local_definition, :score_2_local_definition, :score_3_local_definition, :score_4_local_definition)
  end

  def find_domain
    @domain = Domain.custom_csi_domains.find(params[:id])
  end

  def find_domain_group
    @domain_group = DomainGroup.order(:name)
  end
end
