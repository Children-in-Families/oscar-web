module Api
  class CalendarsController < Api::ApplicationController
    def find_event
      render json: current_user.calendars
    end
  end
end
