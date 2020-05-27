module Api
  class TownshipsController < Api::ApplicationController
    def index
      townships = State.find(params[:state_id]).townships
      render json: { data: townships }
    end
  end
end
