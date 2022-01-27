module Api
  class ProgramStreamAddRuleController < Api::ApplicationController
    def get_fields
      if params[:entity_type] == 'Client'
        @program_stream_fields = AdvancedSearches::RuleFields.new(user: current_user, called_in: 'ProgramStreamAddRuleController').render
      elsif params[:entity_type] == 'Family'
        @program_stream_fields = AdvancedSearches::Families::FamilyFields.new(user: current_user, pundit_user: pundit_user, called_in: 'ProgramStreamAddRuleController').render
      elsif params[:entity_type] == 'Community'
        @program_stream_fields = AdvancedSearches::Communities::CommunityFields.new(user: current_user, pundit_user: pundit_user, called_in: 'ProgramStreamAddRuleController').render
      end
      render json: @program_stream_fields
    end
  end
end
