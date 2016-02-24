class HomeController < ApplicationController
  def index
    @clients = Client.all.includes(:received_by, :followed_up_by).paginate(page: params[:page], per_page: 20)
  end

  def robots
    robots = File.read(Rails.root + "config/robots/#{Rails.env}.txt")
    render text: robots, layout: false, content_type: 'text/plain'
  end
end
