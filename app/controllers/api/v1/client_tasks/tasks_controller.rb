module Api
  module V1
    module ClientTasks
      class TasksController < Api::V1::BaseApiController
        before_action :find_client
        before_action :find_task, only: [:update, :destroy]

        def create
          task = @client.tasks.new(task_params)
          task.user_id = current_user.id

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
          params.require(:task).permit(:domain_id, :name, :completion_date, :expected_date, :remind_at)
        end

        def find_task
          @task = @client.tasks.incomplete.find(params[:id])
        end
      end
    end
  end
end
