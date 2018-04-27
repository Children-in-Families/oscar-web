module Api
  class TownshipsController < AdminController
    def index
      townships = State.find(params[:state_id]).townships
      render json: townships
    end
  end
end
