class DomainGroupsController < AdminController
  load_and_authorize_resource

  before_action :find_domain_group, only: [:update, :destroy]

  def index
    @domain_groups = DomainGroup.all.page(params[:page]).per(20)
  end

  def create
    @domain_group = DomainGroup.new(domain_group_params)
    if @domain_group.save
      redirect_to domain_groups_path, notice: t('.successfully_created')
    else
      redirect_to domain_groups_path, alert: t('.failed_create')
    end
  end

  def update
    if @domain_group.update_attributes(domain_group_params)
      redirect_to domain_groups_path, notice: t('.successfully_updated')
    else
      redirect_to domain_groups_path, alert: t('.failed_update')
    end
  end

  def destroy
    if @domain_group.domains_count.zero?
      @domain_group.destroy
      redirect_to domain_groups_url, notice: t('.successfully_deleted')
    else
      redirect_to domain_groups_path, alert: t('.failed_delete')
    end
  end

  def version
    @domain_group = DomainGroup.find(params[:domain_group_id])
    @versions     = @domain_group.versions.reorder(created_at: :desc).decorate
  end

  private

  def domain_group_params
    params.require(:domain_group).permit(:name, :description)
  end

  def find_domain_group
    @domain_group = DomainGroup.find(params[:id])
  end
end
