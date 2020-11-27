module Api
  class ProgramStreamsController < Api::ApplicationController
    before_action :find_program_stream, only: :update
    before_action :find_entity_type, only: [:enrollment_fields, :tracking_fields]

    def enrollment_fields
      properties = Hash.new { |h,k| h[k] = []}
      program_stream = ProgramStream.find params[:program_stream_id]

      if @entity_type == 'Client'
        client_enrollment_ids = ClientEnrollment.find_by_program_stream_id(program_stream.id).ids
        file_uploader = FormBuilderAttachment.find_by_form_buildable(client_enrollment_ids, 'ClientEnrollment').where("form_builder_attachments.file != '[]'").pluck(:name)
        program_stream.client_enrollments.pluck(:properties).map{|props| props.each{|k, v| properties[k] << v if v.try(:first).present? } }
      else
        enrollment_ids = Enrollment.find_by_program_stream_id(program_stream.id).ids
        file_uploader = FormBuilderAttachment.find_by_form_buildable(enrollment_ids, 'Enrollment').where("form_builder_attachments.file != '[]'").pluck(:name)
        program_stream.enrollments.pluck(:properties).map{|props| props.each{|k, v| properties[k] << v if v.try(:first).present? } }
      end

      custom_field_keys = properties.keys
      custom_field_keys = custom_field_keys += file_uploader
      render json: custom_field_keys
    end

    def tracking_fields
      tracking_properties = Hash.new { |h,k| h[k] = []}
      program_stream = ProgramStream.find params[:program_stream_id]
      properties = {}
      program_stream.trackings.each do |tracking|
        if @entity_type == 'Client'
          client_enrollment_tracking_ids = ClientEnrollmentTracking.enrollment_trackings_by(tracking.id).ids
          file_uploader = FormBuilderAttachment.find_by_form_buildable(client_enrollment_tracking_ids, 'ClientEnrollmentTracking').where("form_builder_attachments.file != '[]'").pluck(:name)
          tracking.client_enrollment_trackings.pluck(:properties).map{|props| props.each{|k, v| tracking_properties[k] << v if v.try(:first).present? } }
        else
          enrollment_tracking_ids = EnrollmentTracking.enrollment_trackings_by(tracking.id).ids
          file_uploader = FormBuilderAttachment.find_by_form_buildable(enrollment_tracking_ids, 'EnrollmentTracking').where("form_builder_attachments.file != '[]'").pluck(:name)
          tracking.enrollment_trackings.pluck(:properties).map{|props| props.each{|k, v| tracking_properties[k] << v if v.try(:first).present? } }
        end
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
      program_stream.leave_programs.pluck(:properties).map{|props| props.each{|k, v| properties[k] << v if v.try(:first).present? } }

      custom_field_keys = properties.keys
      custom_field_keys = custom_field_keys += file_uploader
      render json: custom_field_keys
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

    def list_program_enrollments
      render json: EnrollmentDatatable.new(view_context), root: :data
    end

    private

      def find_program_stream
        @program_stream = ProgramStream.find(params[:id])
      end

      def program_stream_params
        params[:program_stream][:service_ids] = params[:program_stream][:service_ids].uniq
        params.require(:program_stream).permit(:name, service_ids: [])
      end

      def find_entity_type
        @entity_type = params[:entity_type]
      end
  end
end
