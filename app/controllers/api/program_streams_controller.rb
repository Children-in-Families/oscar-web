module Api
  class ProgramStreamsController < AdminController
    def enrollment_fields
      program_stream = ProgramStream.find params[:program_stream_id]
      properties = program_stream.client_enrollments.pluck(:properties).select(&:present?).map(&:keys).flatten.uniq
      render json: properties
    end

    def tracking_fields
      program_stream = ProgramStream.find params[:program_stream_id]
      properties = {}
      program_stream.trackings.each do |tracking|
        properties.store(tracking.name,tracking.client_enrollment_trackings.pluck(:properties).select(&:present?).map(&:keys).flatten.uniq)
      end
      render json: properties
    end

    def exit_program_fields
      program_stream = ProgramStream.find params[:program_stream_id]
      properties = program_stream.leave_programs.pluck(:properties).select(&:present?).map(&:keys).flatten.uniq
      render json: properties
    end
  end
end
