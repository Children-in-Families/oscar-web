module Api
  class ProgramStreamsController < Api::ApplicationController
    before_action :find_program_stream, only: :update
    def enrollment_fields
      program_stream = ProgramStream.find params[:program_stream_id]
      client_enrollment_ids = ClientEnrollment.find_by_program_stream_id(program_stream.id).ids
      file_uploader = FormBuilderAttachment.find_by_form_buildable(client_enrollment_ids, 'ClientEnrollment').where("form_builder_attachments.file != '[]'").pluck(:name)
      properties = program_stream.client_enrollments.pluck(:properties).select(&:present?).map(&:keys).flatten.uniq
      properties += file_uploader
      render json: properties
    end

    def tracking_fields
      program_stream = ProgramStream.find params[:program_stream_id]
      properties = {}
      program_stream.trackings.each do |tracking|
        client_enrollment_tracking_ids = ClientEnrollmentTracking.enrollment_trackings_by(tracking.id).ids
        file_uploader = FormBuilderAttachment.find_by_form_buildable(client_enrollment_tracking_ids, 'ClientEnrollmentTracking').where("form_builder_attachments.file != '[]'").pluck(:name)
        tracking_fields = tracking.client_enrollment_trackings.pluck(:properties).select(&:present?).map(&:keys).flatten.uniq
        tracking_fields += file_uploader
        properties.store(tracking.name, tracking_fields)
      end
      render json: properties.merge(field: 'tracking')
    end

    def exit_program_fields
      program_stream = ProgramStream.find params[:program_stream_id]
      leave_program_ids = LeaveProgram.find_by_program_stream_id(program_stream.id).ids
      file_uploader = FormBuilderAttachment.find_by_form_buildable(leave_program_ids, 'LeaveProgram').where("form_builder_attachments.file != '[]'").pluck(:name)
      properties = program_stream.leave_programs.pluck(:properties).select(&:present?).map(&:keys).flatten.uniq
      properties += file_uploader
      render json: properties
    end

    def update
      if @program_stream.update_attributes(program_stream_params)
        render json: @program_stream
      else
        render json: @program_stream.errors, status: :unprocessable_entity
      end
    end

    def list_program_streams
      render json: TrackingDatatable.new(view_context), root: :data
    end

    private

      def find_program_stream
        @program_stream = ProgramStream.without_deleted.find(params[:id])
      end

      def program_stream_params
        params[:program_stream][:service_ids] = params[:program_stream][:service_ids].uniq
        params.require(:program_stream).permit(:name, service_ids: [])
      end
  end
end
