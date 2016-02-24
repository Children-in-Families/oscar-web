class DomainsController < ApplicationController
  load_and_authorize_resource

  before_action :find_domain, only: [:edit, :update, :destroy]
  before_action :find_domain_group, except: [:index, :destroy]

  def index
    @domains = Domain.all.paginate(page: params[:page], per_page: 10)
  end

  def new
    @domain = Domain.new
  end

  def create
    @domain = Domain.new(domain_params)
    if @domain.save
      redirect_to domains_path, notice: 'កត្តាបង្កើតបានជោគជ័យ / Domain has been successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @domain.update_attributes(domain_params)
      redirect_to domains_path, notice: 'កត្តាsaveបានជោគជ័យ / Domain has been successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if @domain.tasks_count.zero?
      @domain.destroy
      redirect_to domains_url, notice: 'កត្តាត្រូវបានលុបចោលជោគជ័យ / Domain has been successfully deleted.'
    else
      redirect_to domains_url, alert: 'Domain cannot be deleted.'
    end
  end

  private

  def domain_params
    params.require(:domain).permit(:name, :identity, :description, :domain_group_id)
  end

  def find_domain
    @domain = Domain.find(params[:id])
  end

  def find_domain_group
    @domain_group = DomainGroup.order(:name)
  end

end
