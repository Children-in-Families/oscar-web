module Api
  module V1
    class ClientsController < Api::V1::BaseApiController
      before_action :find_client, except: [:index, :create]

      def index
        clients = current_user.clients
        render json: clients
      end

      def show
        respond_to do |format|
          format.html do
            render json: @client
          end
          format.pdf do
            @interviewee_names = @client.interviewees.pluck(:name)
            @client_type_names = @client.client_types.pluck(:name)
            pdf = render_to_string pdf:      'show',
                    template: 'clients/show.pdf.haml',
                    page_size: 'A4',
                    layout:   'pdf_design.html.haml',
                    show_as_html: params.key?('debug'),
                    header: { html: { template: 'government_reports/pdf/header.pdf.haml' } },
                    footer: { html: { template: 'government_reports/pdf/footer.pdf.haml' }, right: '[page] of [topage]' },
                    margin: { left: 0, right: 0, top: 10 },
                    dpi: '72',
                    disposition: 'inline'
            send_data pdf
          end
        end
      end

      def create
        client = Client.new(client_params)
        if client.save
          render json: client
        else
          render json: client.errors, status: :unprocessable_entity
        end
      end

      def update
        if @client.update_attributes(client_params)
          render json: @client
        else
          render json: @client.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @client.reload.destroy
        head 204
      end

      private

      def find_client
        @client = Client.accessible_by(current_ability).find(params[:id])
      end

      def client_params
        params.require(:client)
              .permit(
                :kid_id, :assessment_id, :given_name, :family_name, :local_given_name, :local_family_name, :gender, :date_of_birth,
                :birth_province_id, :initial_referral_date, :referral_source_id,
                :referral_phone, :received_by_id, :followed_up_by_id,
                :follow_up_date, :grade, :school_name, :current_address,
                :house_number, :street_number, :village, :commune, :district,
                :has_been_in_orphanage, :has_been_in_government_care,
                :relevant_referral_information, :province_id, :donor_id,
                :state, :rejected_note, :able, :able_state, :id_poor, :live_with, :accepted_date, :exit_note, :exit_date,
                user_ids: [],
                agency_ids: [],
                quantitative_case_ids: [],
                custom_field_ids: [],
                tasks_attributes: [:name, :domain_id, :completion_date],
                answers_attributes: [:id, :description, :able_screening_question_id, :client_id, :question_type]
              )
      end
    end
  end
end
