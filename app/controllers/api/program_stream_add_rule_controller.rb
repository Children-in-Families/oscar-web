module Api
  class ProgramStreamAddRuleController < Api::ApplicationController
    def get_fields
      @program_stream_fields = AdvancedSearches::RuleFields.new(user: current_user).render
      render json: @program_stream_fields
    end
  end
end
