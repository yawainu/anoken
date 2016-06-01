class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(username: params[:session][:username])
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_back_or admin_path
    else
      flash.now[:danger] = "正しくない情報です"
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to signin_path
  end
end
