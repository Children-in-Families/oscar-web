module Api
  module V1
    class TasksController < Api::V1::BaseApiController
      def index
        tasks = Task.incomplete.of_user(current_user)
        overdue = tasks.overdue.group_by
        duetoday = tasks.today.group_by
        upcoming = tasks.upcoming.group_by
        render json: {tasks: {overdue: overdue, duetoday: duetoday, upcoming: upcoming}}
      end
    end
  end
end
