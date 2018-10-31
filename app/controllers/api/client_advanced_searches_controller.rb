module Api
  class ClientAdvancedSearchesController < Api::ApplicationController
    def get_basic_field
      advanced_filter_fields = AdvancedSearches::ClientFields.new(user: current_user).render
      render json: advanced_filter_fields
    end

    def get_custom_field
      custom_form_ids = params[:ids]
      advanced_filter_custom_field = AdvancedSearches::CustomFields.new(custom_form_ids).render
      advanced_filter_custom_field << AdvancedSearches::HasThisFormFields.new(custom_form_ids).render.first
      render json: advanced_filter_custom_field
    end

    def get_enrollment_field
      program_stream_ids = params[:ids]
      advanced_filter_enrollment_field = AdvancedSearches::EnrollmentFields.new(program_stream_ids).render
      render json: advanced_filter_enrollment_field
    end

    def get_tracking_field
      program_stream_ids = params[:ids]
      advanced_filter_tracking_field = AdvancedSearches::TrackingFields.new(program_stream_ids).render
      render json: advanced_filter_tracking_field
    end

    def get_exit_program_field
      program_stream_ids = params[:ids]
      advanced_filter_exit_program_field = AdvancedSearches::ExitProgramFields.new(program_stream_ids).render
      render json: advanced_filter_exit_program_field
    end
  end
end
