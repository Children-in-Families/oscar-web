module Api
  module V1
    class ScreeningAssessmentsController < Api::V1::BaseApiController
      before_action :find_client
      before_action :find_screening_assessment, except: %i[index create]

      def index
        screen_assessments = @client.screening_assessments
        render json: screen_assessments
      end

      def show
        render json: @screening_assessment
      end

      def create
        screening_assessment = @client.screening_assessments.new(screening_assessment_params)
        if screening_assessment.save
          render json: screening_assessment
        else
          render json: screening_assessment.errors.full_messages, status: :unprocessable_entity
        end
      end

      def update
        if @screening_assessment.update_attributes(screening_assessment_params)
          render json: @screening_assessment
        else
          render json: @screening_assessment.errors.full_messages, status: :unprocessable_entity
        end
      end

      def destroy
        @screening_assessment.destroy
        head 204
      end

      private

      def screening_assessment_params
        params.require(:screening_assessment)
              .permit(
                :screening_assessment_date, :client_age, :visitor, :client_milestone_age, :note,
                :smile_back_during_interaction, :follow_object_passed_midline, :turn_head_to_sound,
                :head_up_45_degree, :screening_type, :client_id,
                attachments: [],
                developmental_marker_screening_assessments_attributes: %i[id developmental_marker_id question_1 question_2 question_3 question_4 _destroy],
                tasks_attributes: %i[id client_id name expected_date completion_date taskable_id taskable_type relation _destroy]
              )
      end

      def find_screening_assessment
        @screening_assessment = @client.screening_assessments.find(params[:id])
      end
    end
  end
end
