class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user

  def render_404
    return render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  private

  def find_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    end
  end

  before_action :require_login

  def require_login
    @current_user = User.find(session[:user_id])
    if @current_user.nil?
      flash[:status] = :failure
      flash[:result_text] = "You must be logged in to view this section"
      redirect_to login_path
    end
  end
end
