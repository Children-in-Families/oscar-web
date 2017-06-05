module Api
  module V1
    class TasksController < Api::V1::BaseApiController
      before_action :find_client
      before_action :find_task, only: [:update, :destroy]

      def create
        task = @client.tasks.new(task_params)

        if task.save
          render json: task
        else
          render json: task.errors, status: :unprocessable_entity
        end
      end

      def update
        if @task.update_attributes(task_params)
          render json: @task
        else
          render json: @task.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @task.destroy
        head 204
      end

      private

      def task_params
        permitted_params = params.require(:task).permit(:domain_id, :name, :completion_date, :remind_at)
        permitted_params.merge({ user_id: @client.user.id }) if @client.user
      end

      def find_task
        @task = @client.tasks.incomplete.find(params[:id])
      end
    end
  end
end
