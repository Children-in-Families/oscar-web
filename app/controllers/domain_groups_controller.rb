class DomainGroupsController < ApplicationController
  load_and_authorize_resource

  before_action :find_domain_group, only: [:edit, :update, :destroy]  

  def index
    @domain_groups = DomainGroup.all.paginate(page: params[:page], per_page: 10)
  end

  def new
    @domain_group = DomainGroup.new
  end

  def create
    @domain_group = DomainGroup.new(domain_group_params)
    if @domain_group.save
      redirect_to domain_groups_path, notice: 'ការប្រមូលផ្តុំកត្តាបង្កើតបានជោគជ័យ / Domain Group has been successfully created.'
    else
      render :new
    end    
  end

  def edit
  end

  def update
    if @domain_group.update_attributes(domain_group_params)
      redirect_to domain_groups_path, notice: 'ការប្រមូលផ្តុំកត្តាsaveបានជោគជ័យ / Domain Group has been successfully updated.'
    else
      render :edit
    end    
  end
  
  def destroy
    if @domain_group.domains_count.zero?
      @domain_group.destroy
      redirect_to domain_groups_url, notice: 'ការប្រមូលផ្តុំ​កត្តាត្រូវបានលុបចោលជោគជ័យ / Domain Group has been successfully deleted.'
    else
      redirect_to domain_groups_url, alert: 'Domain Group cannot be deleted.'
    end
  end

  private

  def domain_group_params
    params.require(:domain_group).permit(:name, :description)
  end

  def find_domain_group
    @domain_group = DomainGroup.find(params[:id])
  end
  
end