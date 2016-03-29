# -*- encoding : utf-8 -*-

class UserController < ApplicationController
   before_filter :controle_acces, :except => [:logout, :login]

   def login
      if request.post?
#         reset_session
         session[:user_id] = nil
         @user = User.authenticate(params[:login], params[:password])
         if @user
            session[:user_id] = @user.user_id
            # this function must be decommented when guest_user is enabled.
            transfer_guest_user_actions_to_current_user
            
            #logger.info 'log : ' + @user.first_name  
            uri = session[:asked_page]
            session[:asked_page] = nil
            
            if !uri.nil?
              redirect_to uri
            else
              redirect_to '/user/compte'
            end
         else
            flash[:alert] = "Utilisateur ou mot de passe invalide"
         end
      end
   end
   
   def logout
      #détruit la session de l'utilisateur courant
      reset_session
      redirect_to :root
   end
   
   #accès à la page lecteur
   def compte      
      login = session[:user_id]
      user_found = User.where(:user_id => login).first         
      password = User.get_decrypted_password(user_found.password)
      @user = User.authenticate( login, password )
   end
   
   #contrôleur pour la réservation d'un exemplaire
   def reservation
#      Rails.logger.debug 'Bug04091236 : ' + params[:barcode].inspect
         if  params[:barcode].nil?
            redirect_to '/user/compte' 
            return
         end      
         barcode = User.clean_barcode( params[:barcode], params[:succursale] ) 

         if params[:cancel] == '1'
            flash[:alert] = current_user.cancel_reservation( barcode )
            redirect_to '/user/compte'            
         end
             
         if params[:confirmation] == '1'
            reservation = current_user.reservation( barcode )
            flash[:alert] = reservation

            if reservation == 'Votre réservation a été enregistrée'
               redirect_to '/user/compte'
            else
               uri = session[:previous_page]
               session[:previous_page] = nil
               redirect_to uri
            end
         elsif params[:confirmation] == '0'
            flash[:alert] = 'Votre demande a été annulée.'
            uri = session[:previous_page]
            session[:previous_page] = nil
            redirect_to uri
         else
            session[:previous_page] = request.referer if session[:previous_page].nil?
         end 
   end
   
   def renew_loan      
      if  params[:barcode].nil?
            redirect_to '/user/compte' 
            return
      end
      barcode = User.clean_barcode( params[:barcode], params[:succursale] )
      flash[:alert] = current_user.renew_loan( barcode )
#     Rails.logger.debug 'Bug 1553 : reponse : ' + renew.inspect
      redirect_to '/user/compte'
   end
   
   def communication
      if  params[:barcode].nil?
            redirect_to '/user/compte' 
            return
      end
      
      if params[:confirmation] == '1'
        infos = {}
        infos[:barcode] = User.clean_barcode( params[:barcode], params[:succursale] ) 
        infos[:cote] = params[:cote]
        infos[:cote_suppl] = params[:cote_suppl]
        infos[:impression] = params[:impression]
        communication = current_user.communication( infos )
         flash[:alert] = communication
         redirect_to '/user/compte'
#        if communication 
#           redirect_to '/user/compte'
#           flash[:alert] = 'Le bulletin de demande a été envoyé'
#        else
##           uri = session[:previous_page]
##           session[:previous_page] = nil
##           redirect_to uri
#            
#            flash[:alert] = 'Le bulletin de demande n\'a été envoyé.'
#        end
      elsif params[:confirmation] == '0'
        flash[:alert] = 'Votre demande a été annulée.'
        uri = session[:previous_page]
        session[:previous_page] = nil
        redirect_to uri
      else
        session[:previous_page] = request.referer if session[:previous_page].nil?
      end
   end
end 
