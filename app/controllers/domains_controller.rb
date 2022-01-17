class DomainsController < AdminController
  load_and_authorize_resource

  before_action :find_domain, only: [:edit, :update, :destroy]
  before_action :find_domain_group, except: [:index, :destroy]
  before_action :find_custom_assessment_settings, :find_custom_assessment_setting, except: :index

  def index
    @domains = Domain.csi_domains.page(params[:page_1]).per(10)
    @custom_domains = Domain.custom_csi_domains.page(params[:page_2]).per(10)
    @results = Domain.csi_domains.count
    @custom_domain_results = Domain.custom_csi_domains.count
    @custom_assessment_settings = @current_setting.custom_assessment_settings.where(enable_custom_assessment: true)
    @custom_assessment_paginate = @custom_assessment_settings.joins(:domains).distinct.page(params[:page_2]).per(10)
    @family_custom_domains = Domain.family_custom_csi_domains.page(params[:page_2]).per(10)
  end

  def new
    if params[:copy] != 'true'
      @domain = Domain.new(custom_assessment_setting_id: params[:custom_assessment_setting_id], domain_type: params[:domain_type])
    else
      @domain     = Domain.find(params[:domain_id])
      domain_attr = @domain.attributes.except('id')
      @domain     = Domain.new(domain_attr.merge(domain_type: params[:domain_type]))
    end
  end

  def create
    @domain = Domain.new(domain_params)
    @domain.custom_domain = true
    if @domain.save
      redirect_to domains_path(tab: tab_name), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @domain.update_attributes(domain_params)
      redirect_to domains_path(tab: tab_name), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @domain.destroy
      redirect_to domains_path(tab: tab_name), notice: t('.successfully_deleted')
    else
      redirect_to domains_path(tab: tab_name), alert: t('.alert')
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
      :score_1_local_definition, :score_2_local_definition, :score_3_local_definition, :score_4_local_definition,
      :custom_assessment_setting_id, :domain_type,
      :score_5_color, :score_6_color, :score_7_color, :score_8_color, :score_9_color, :score_10_color,
      :score_5_definition, :score_6_definition, :score_7_definition, :score_8_definition, :score_9_definition, :score_10_definition,
      :score_5_local_definition, :score_6_local_definition, :score_7_local_definition, :score_8_local_definition, :score_9_local_definition, :score_10_local_definition
      )
  end

  def find_domain
    @domain = Domain.custom_domains.find(params[:id])
  end

  def find_domain_group
    @domain_group = DomainGroup.order(:name)
  end

  def find_custom_assessment_settings
    @custom_assessment_settings = CustomAssessmentSetting.all.where(enable_custom_assessment: true)
  end

  def find_custom_assessment_setting
    @custom_assessment_setting = CustomAssessmentSetting.find(params[:custom_assessment_setting_id]) if params[:custom_assessment_setting_id].present?
  end

  def tab_name
    return "#{@custom_assessment_setting.custom_assessment_name.downcase.strip.parameterize('-')}#{@custom_assessment_setting.id}-custom-csi-tools" if @custom_assessment_setting
    params[:tab].presence || 'csi-tools'
  end
end
