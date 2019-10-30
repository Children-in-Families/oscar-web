module Api
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session, except: :index, if: proc { |c| c.request.format == 'application/json' }
    before_action :authenticate_user!
  end
end
