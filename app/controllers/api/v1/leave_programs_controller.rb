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
        params.require(:leave_program).permit(:exit_date, {}).merge(properties: params[:leave_program][:properties], program_stream_id: params[:program_stream_id])
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
