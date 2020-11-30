module Api
  class ProgramStreamAddRuleController < Api::ApplicationController
    def get_fields
      if params[:entity_type] == 'Client'
        @program_stream_fields = AdvancedSearches::RuleFields.new(user: current_user).render
      elsif params[:entity_type] == 'Family'
        @program_stream_fields = AdvancedSearches::Families::FamilyFields.new(user: current_user, pundit_user: pundit_user).render
      end
      render json: @program_stream_fields
    end
  end
end
