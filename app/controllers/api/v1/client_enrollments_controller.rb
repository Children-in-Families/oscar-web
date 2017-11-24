module Api
  module V1
    class ClientEnrollmentsController < Api::V1::BaseApiController
      include FormBuilderAttachments

      before_action :find_client
      before_action :find_client_enrollment, only: [:update, :destroy]

      def create
        @client_enrollment = @client.client_enrollments.new(client_enrollment_params)
        if @client_enrollment.save
          @client_enrollment.form_builder_attachments.map do |c|
            @client_enrollment.properties = @client_enrollment.properties.merge({ c.name => c.file })
          end
          render json: @client_enrollment
        else
          render json: @client_enrollment.errors, status: :unprocessable_entity
        end
      end

      def update
        if @client_enrollment.update_attributes(client_enrollment_params)
          add_more_attachments(@client_enrollment)
          @client_enrollment.form_builder_attachments.map do |c|
            @client_enrollment.properties = @client_enrollment.properties.merge({ c.name => c.file })
          end
          render json: @client_enrollment
        else
          render json: @client_enrollment.errors, status: :unprocessable_entity
        end
      end

      def destroy
        name = params[:file_name]
        index = params[:file_index].to_i

        if name.present? && index.present?
          delete_form_builder_attachment(@client_enrollment, name, index)
        else
          @client_enrollment.destroy
          head 204
        end
      end

      private

      def client_enrollment_params
        properties_params.values.map{ |v| v.delete('') if (v.is_a?Array) && v.size > 1 } if properties_params.present?

        default_params = params.require(:client_enrollment).permit(:enrollment_date).merge!(program_stream_id: params[:program_stream_id])
        default_params = default_params.merge!(properties: properties_params) if properties_params.present?
        default_params = default_params.merge!(form_builder_attachments_attributes: params[:client_enrollment][:form_builder_attachments_attributes]) if action_name == 'create' && attachment_params.present?
        default_params
      end

      def find_client_enrollment
        @client_enrollment = @client.client_enrollments.find(params[:id])
      end

      def find_client
        @client = Client.accessible_by(current_ability).find(params[:client_id])
      end
    end
  end
end
