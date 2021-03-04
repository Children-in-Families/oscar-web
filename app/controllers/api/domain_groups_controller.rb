module Api
  class DomainGroupsController < Api::ApplicationController
    def get_domains_by_domain_groups
      data = get_domains.map {|domain| [domain.id, "#{domain.name}: #{domain.identity}"] }
      render json: { data: data }
    end

    private

    def get_domains
      domain_groups = JSON.parse(params[:domain_group_ids])
      if params[:custom] == 'true'
        Domain.where(domain_group_id: domain_groups, custom_assessment_setting_id: params['custom_assessment_setting_id']).custom_csi_domains
      elsif params[:family] == 'true'
        Domain.where(domain_group_id: domain_groups).family_custom_csi_domains
      else
        Domain.where(domain_group_id: domain_groups).csi_domains
      end
    end
  end
end
