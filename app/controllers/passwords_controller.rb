class PasswordsController < Devise::PasswordsController
  def user_for_paper_trail
    params[:user][:email] if params[:user] && params[:user][:email]
  end
end
