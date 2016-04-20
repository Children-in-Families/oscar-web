module Api
  module V1
    class TasksController < Api::V1::BaseApiController
      before_action :find_client

      def create
        task = @client.tasks.new(task_params)
        task.user_id = @client.user.id if @client.user

        if task.save
          render json: { id: task.id }
        else
          render json: task.errors, status: :unprocessable_entity
        end
      end

      private

      def task_params
        params.require(:task).permit(:domain_id, :name, :completion_date, :remind_at)
      end
    end
  end
end
