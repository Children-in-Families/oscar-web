module Api
  class ProgramStreamAddRuleController < AdminController
    def get_fields
      @program_stream_fields = AdvancedSearches::ClientFields.new(user: current_user).render
      render json: @program_stream_fields
    end
  end
end
