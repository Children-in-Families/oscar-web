module Api
  module V1
    class ClientEnrollmentTrackingsController < Api::V1::BaseApiController
      include FormBuilderAttachments

      before_action :find_client, :find_enrollment
      before_action :find_client_enrollment_tracking, only: [:update, :destroy]

      def create
        @client_enrollment_tracking = @enrollment.client_enrollment_trackings.new(client_enrollment_tracking_params)
        if @client_enrollment_tracking.save
          @client_enrollment_tracking.form_builder_attachments.map do |c|
            @client_enrollment_tracking.properties = @client_enrollment_tracking.properties.merge({ c.name => c.file })
          end
          render json: @client_enrollment_tracking
        else
          render json: @client_enrollment_tracking.errors, status: :unprocessable_entity
        end
      end

      def update
        if @client_enrollment_tracking.update_attributes(client_enrollment_tracking_params)
          add_more_attachments(@client_enrollment_tracking)
          @client_enrollment_tracking.form_builder_attachments.map do |c|
            @client_enrollment_tracking.properties = @client_enrollment_tracking.properties.merge({ c.name => c.file })
          end
          render json: @client_enrollment_tracking
        else
          render json: @client_enrollment_tracking.errors, status: :unprocessable_entity
        end
      end

      def show
      end

      def destroy
        name = params[:file_name]
        index = params[:file_index].to_i
        notice = ""
        if name.present? && index.present?
          delete_form_builder_attachment(@client_enrollment_tracking, name, index)
        else
          @client_enrollment_tracking.destroy
          head 204
        end
      end

      private

      def client_enrollment_tracking_params
        trackings_fields = Tracking.find(params[:tracking_id]).fields.map{|c| [c['name'], c['label'], c['type']]}
        trackings_fields.each do |name, label, type|
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

        default_params = params.require(:client_enrollment_tracking).permit({}).merge!(tracking_id: params[:tracking_id])
        default_params = default_params.merge!(properties: properties_params) if properties_params.present?
        default_params = default_params.merge!(form_builder_attachments_attributes: params[:client_enrollment_tracking][:form_builder_attachments_attributes]) if action_name == 'create' && attachment_params.present?
        default_params
      end

      def find_client
        @client = Client.accessible_by(current_ability).friendly.find params[:client_id]
      end

      def find_enrollment
        @enrollment = @client.client_enrollments.find params[:client_enrollment_id]
      end

      def find_client_enrollment_tracking
        @client_enrollment_tracking = @enrollment.client_enrollment_trackings.find params[:id]
      end
    end
  end
end
