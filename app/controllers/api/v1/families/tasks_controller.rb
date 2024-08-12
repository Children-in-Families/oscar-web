module Api
  module V1
    module Families
      class TasksController < Api::V1::BaseApiController
        before_action :set_family
        before_action :find_task, only: %i[update destroy]

        def index
          tasks = @family.tasks.includes(:domain)
          render json: tasks
        end

        def create
          task = @family.tasks.new(task_params)
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

        def set_family
          @family = Family.accessible_by(current_ability).find(params[:family_id])
        end

        def find_task
          @task = @family.tasks.incomplete.find(params[:id])
        end
      end
    end
  end
end
