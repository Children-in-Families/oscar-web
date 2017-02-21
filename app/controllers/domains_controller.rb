class DomainsController < AdminController
  load_and_authorize_resource

  before_action :find_domain, only: [:edit, :update, :destroy]
  before_action :find_domain_group, except: [:index, :destroy]

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
    @domain   = Domain.find(params[:domain_id])
    @versions = @domain.versions.reorder(created_at: :desc).page(params[:page]).per(10)
  end

  private

  def domain_params
    params.require(:domain).permit(:name, :identity, :description, :domain_group_id, :score_1_color, :score_2_color, :score_3_color, :score_4_color)
  end

  def find_domain
    @domain = Domain.find(params[:id])
  end

  def find_domain_group
    @domain_group = DomainGroup.order(:name)
  end
end
