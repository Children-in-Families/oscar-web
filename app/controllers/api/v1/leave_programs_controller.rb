module Api
  module V1
    class LeaveProgramsController < Api::V1::BaseApiController
      include FormBuilderAttachments

      before_action :find_client, :find_enrollment

      def create
        @leave_program = @enrollment.create_leave_program(leave_program_params)
        if @leave_program.save
          @leave_program.client_enrollment.update_columns(status: 'Exited')
          @leave_program.form_builder_attachments.map do |c|
            @leave_program.properties = @leave_program.properties.merge({ c.name => c.file })
          end
          render json: @leave_program
        else
          render json: @leave_program.errors, status: :unprocessable_entity
        end
      end

      def update
        @leave_program = @enrollment.leave_program
        if @leave_program.update_attributes(leave_program_params)
          add_more_attachments(@leave_program)
          @leave_program.form_builder_attachments.map do |c|
            @leave_program.properties = @leave_program.properties.merge({ c.name => c.file })
          end
          render json: @leave_program
        else
          render json: @leave_program.errors, status: :unprocessable_entity
        end
      end

      private

      def leave_program_params
        exit_program_fields = ProgramStream.find(params[:program_stream_id]).exit_program.map{|c| [c['name'], c['label'], c['type']]}
        exit_program_fields.each do |name, label, type|
          if type == 'file' && attachment_params.present?
            attachment_params.values.each do |attachment|
              attachment['name'] = label if attachment['name'] == name
            end
          end
          if type != 'file' && properties_params.present?
            properties_params.keys.each do |key|
              properties_params[label] = properties_params.delete key if key == name
            end
          end
        end
        properties_params.values.map{ |v| v.delete('') if (v.is_a?Array) && v.size > 1 } if properties_params.present?

        default_params = params.require(:leave_program).permit(:exit_date).merge!(program_stream_id: params[:program_stream_id])
        default_params = default_params.merge!(properties: properties_params) if properties_params.present?
        default_params = default_params.merge!(form_builder_attachments_attributes: params[:leave_program][:form_builder_attachments_attributes]) if action_name == 'create' && attachment_params.present?
        default_params
      end

      def find_client
        @client = Client.accessible_by(current_ability).friendly.find params[:client_id]
      end

      def find_enrollment
        @enrollment = @client.client_enrollments.find params[:client_enrollment_id]
      end
    end
  end
end
