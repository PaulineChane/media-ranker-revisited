class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def render_404
    return render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  private

  before_action :require_login

  def current_user
    @current_user = session[:user_id].nil? ? nil : User.find(session[:user_id])
  end

  def require_login
    if current_user.nil?
      flash[:status] = :failure
      flash[:result_text] = "You must log in to do that"
      redirect_to root_path
    end
  end
end
