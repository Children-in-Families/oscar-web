module Api
  class ApplicationController < ActionController::Base
    before_action :authenticate_user!
    before_action :set_paper_trail_whodunnit
  end
end
