class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout 'blacklight'

  protect_from_forgery with: :exception

  helper_method :current_or_guest_user, :current_user, :user_session, :guest_user
  
   def user_session
      return true if session[:user_id] && User.where(:user_id => session[:user_id]).first    
      false
   end

   def current_or_guest_user
      return guest_user if ! session[:user_id]
      if session[:guest_user_id]
         guest_user.destroy
         session[:guest_user_id] = nil
      end
      current_user
   end

   def current_user
      @current_user ||= User.where(:user_id => session[:user_id]).first
   end
   
   def guest_user
      @guest_user ||= User.find(session[:guest_user_id] ||= create_guest_user.id)
   end

   private
   def create_guest_user
      user = User.create(:user_id => "guest_#{guest_user_unique_id}", :name => "guest")
      user.guest = true
      user.save!
      user
   end
   
   def guest_user_unique_id
      Time.now.to_i.to_s + "_" + unique_user_counter.to_s
   end

   def unique_user_counter
      @@unique_user_counter ||= 0
      @@unique_user_counter += 1
   end

   def controle_acces
      return true if user_session
      session[:previous_page] = request.referer
      session[:asked_page] = request.url           
      flash[:notice] = 'Veuillez vous connecter.'
      redirect_to(:controller =>'user', :action => 'login')
   end
end
