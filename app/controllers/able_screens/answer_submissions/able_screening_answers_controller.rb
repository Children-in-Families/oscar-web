module AbleScreens
  module AnswerSubmissions
    class AbleScreeningAnswersController < AdminController
      load_and_authorize_resource :able_screening_answer, :class => 'Answer', :parent => false
      before_action :set_client

      def new
        @ordered_stage                       = Stage.order('from_age, to_age')
        @able_screening_questions            = AbleScreeningQuestion.with_stage.group_by(&:question_group_id)
        @able_screening_questions_non_stage  = AbleScreeningQuestion.non_stage.order('created_at')
        @able_screening_questions_with_stage = AbleScreeningQuestion.with_stage
        @answers_with_stage = []
        @answers_non_stage = []
        @able_screening_questions_with_stage.each do |question|
          @answers_with_stage <<  @client.answers.build(able_screening_question: question)
        end

        @able_screening_questions_non_stage.each do |question|
          @answers_non_stage <<  @client.answers.build(able_screening_question: question)
        end
      end

      def create
        if @client.update_attributes(answer_params)
          AbleScreeningMailer.notify_able_manager(@client).deliver_now if @client.able?
          redirect_to @client, notice: t('.successfully_created')
        else
          render :new
        end
      end

      private
        def set_client
          @client = Client.friendly.find(params[:client_id])
        end

        def answer_params
          params.require(:client)
                  .permit(answers_attributes:
                          [:id, :description, :able_screening_question_id,
                            :client_id, :question_type]
                          )
        end
    end
  end
end
