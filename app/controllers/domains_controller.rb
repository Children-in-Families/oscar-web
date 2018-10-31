class DomainsController < AdminController
  load_and_authorize_resource

  before_action :find_domain, only: [:edit, :update, :destroy]
  before_action :find_domain_group, except: [:index, :destroy]
  before_action :validate_organization

  def index
    @domains = Domain.all.page(params[:page]).per(10)
    @results = Domain.count
  end

  def new
    @domain = Domain.new
  end

  def create
    @domain = Domain.new(domain_params)
    if @domain.save
      redirect_to domains_path, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @domain.update_attributes(domain_params)
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
    params.require(:domain).permit(:name, :identity, :description, :domain_group_id, :score_1_color, :score_2_color, :score_3_color, :score_4_color, :score_1_definition, :score_2_definition, :score_3_definition, :score_4_definition)
  end

  def find_domain
    @domain = Domain.find(params[:id])
  end

  def find_domain_group
    @domain_group = DomainGroup.order(:name)
  end

  def validate_organization
    redirect_to root_url, alert: t('unauthorized.default') if (Rails.env.production? && current_organization.demo?)
  end
end
