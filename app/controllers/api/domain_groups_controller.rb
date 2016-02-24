module Api
  class DomainGroupsController < BaseApiController

    def update
      domain_group = DomainGroup.find(params[:id])
      if domain_group.update_attributes(domain_group_params)
        head :ok
      else
        render json: domain_group.errors, status: 500
      end
    end

    private
    def domain_group_params
      params.require(:domain_group).permit(case_notes_tasks_attributes: [:id, :name, :kinship_or_foster_care_case_id])
    end
  end
end
