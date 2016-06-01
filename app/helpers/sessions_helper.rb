module SessionsHelper

  def sign_in(user)
    token = User.new_remember_token
    cookies.permanent[:remember_token] = token
    remember_token = user.remember_tokens.where(platform: browser.platform).find_or_initialize_by(browser: browser.name)
    remember_token.update(token: User.encrypt(token))
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    token = User.encrypt(cookies[:remember_token])
    @current_user ||= RememberToken.find_by(token: token).try(:user)
  end

  def current_user?(user)
    user == current_user
  end

  def signed_in_user
    unless signed_in?
      store_location
      flash[:warning] = "ログインしてください"
      redirect_to signin_path
    end
  end

  def signed_out_user
    if signed_in?
      store_location
      flash[:warning] = "ログアウトしてください"
      redirect_to admin_path
    end
  end

  def sign_out
    self.current_user = nil
    session.delete(:return_to)
    cookies.delete(:remember_token)
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end
end
