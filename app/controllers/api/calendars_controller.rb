module Api
  class CalendarsController < Api::ApplicationController
    def find_event
      render json: current_user.calendars.joins(:task).where(tasks: { completed: false })
    end
  end
end
