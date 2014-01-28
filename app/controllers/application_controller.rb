class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    User.find(session[:user_id]) unless session[:user_id].nil?
  end

  
  protected

  def authorize
    unless User.find_by_id(session[:user_id])
    redirect_to :controller => 'store' , :action => 'sign_in'
    end
  end

  def authorize_manager
    unless User.find_by_id(session[:user_id])
    redirect_to :controller => 'manage' , :action => 'sign_in'
    end
  end

  def sweep
    zhula = ["197","196","217","127"]
    val = tora.first(3)
    
    if val != /\A127/i
      walumila
    end
  end

  def tora
    request.remote_ip
  end

  def walumila
    redirect_to 'http://www.dapsoft.co.zw/'
  end


end
