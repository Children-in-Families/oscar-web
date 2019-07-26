class ErrorsController < ApplicationController
  layout false

  def show
    status_code = params[:code] == 404 ? 404 : 500
    render status_code.to_s, status: status_code
  end
end
