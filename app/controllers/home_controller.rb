class HomeController < AdminController
  def index
    @dashboard       = Dashboard.new(current_user)
  end

  def robots
    robots = File.read(Rails.root + "config/robots/#{Rails.env}.txt")
    render text: robots, layout: false, content_type: 'text/plain'
  end
end
