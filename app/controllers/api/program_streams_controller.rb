module Api
  class ProgramStreamsController < Api::ApplicationController
    def enrollment_fields
      properties = Hash.new { |h,k| h[k] = []}
      program_stream = ProgramStream.find params[:program_stream_id]
      client_enrollment_ids = ClientEnrollment.find_by_program_stream_id(program_stream.id).ids
      file_uploader = FormBuilderAttachment.find_by_form_buildable(client_enrollment_ids, 'ClientEnrollment').where("form_builder_attachments.file != '[]'").pluck(:name)
      # properties = program_stream.client_enrollments.pluck(:properties).select(&:present?).map(&:keys).flatten.uniq
      program_stream.client_enrollments.pluck(:properties).map{|props| props.each{|k, v| properties[k] << v if v.first.present? } }

      custom_field_keys = properties.keys
      custom_field_keys = custom_field_keys += file_uploader
      render json: custom_field_keys
    end

    def tracking_fields
      tracking_properties = Hash.new { |h,k| h[k] = []}
      program_stream = ProgramStream.find params[:program_stream_id]
      properties = {}
      program_stream.trackings.each do |tracking|
        client_enrollment_tracking_ids = ClientEnrollmentTracking.enrollment_trackings_by(tracking.id).ids
        file_uploader = FormBuilderAttachment.find_by_form_buildable(client_enrollment_tracking_ids, 'ClientEnrollmentTracking').where("form_builder_attachments.file != '[]'").pluck(:name)
        tracking.client_enrollment_trackings.pluck(:properties).map{|props| props.each{|k, v| tracking_properties[k] << v if v.first.present? } }
        tracking_fields = tracking_properties.keys
        tracking_fields += file_uploader
        properties.store(tracking.name, tracking_fields)
      end

      render json: properties.merge(field: 'tracking')
    end

    def exit_program_fields
      properties = Hash.new { |h,k| h[k] = []}
      program_stream = ProgramStream.find params[:program_stream_id]
      leave_program_ids = LeaveProgram.find_by_program_stream_id(program_stream.id).ids
      file_uploader = FormBuilderAttachment.find_by_form_buildable(leave_program_ids, 'LeaveProgram').where("form_builder_attachments.file != '[]'").pluck(:name)
      program_stream.leave_programs.pluck(:properties).map{|props| props.each{|k, v| properties[k] << v if v.first.present? } }

      custom_field_keys = properties.keys
      custom_field_keys = custom_field_keys += file_uploader
      render json: custom_field_keys
    end

    def list_program_streams
      render json: TrackingDatatable.new(view_context), root: :data
    end
  end
end
