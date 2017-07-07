module Api
  class CalendarsController < AdminController
    def find_event
      render json: current_user.calendars
    end
  end
end
