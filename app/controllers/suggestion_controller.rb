# -*- encoding : utf-8 -*-

class SuggestionController < ApplicationController
   before_filter :controle_acces

   #fonction d'enregistrement d'une suggestion
   def index
      login = session[:user_id]
      @user = User.where(:user_id => login).first
      if request.post?
         #enregistrement d'un ouvrage
         @book = Book.find_or_initialize_by_title(title: params[:title])
         @book.author = params[:author]
         @book.publisher = params[:publisher]
         @book.pub_date = params[:pub_date]
         @book.note = params[:note]
         @book.isbn = params[:isbn]
         @book.save
#         Rails.logger.debug 'book 11h59 : ' + @book.inspect
         
         #enregistrement d'une suggestion
         suggestion = Suggestion.new
         suggestion.user_id = @user.user_id
         suggestion.book_id = @book.id
         suggestion.recipient = params[:recipient]
         suggestion.status = 1
         suggestion.save
         
         #envoi d'un mail
         UserMailer.send_suggestion_to_recipient(@user, @book, params[:recipient], params[:email]).deliver
         UserMailer.send_suggestion_to_lector(@user, @book, params[:recipient], params[:email]).deliver
#         Rails.logger.debug 'validation ok 14h55 : ' + test.inspect
         flash[:success] = 'Votre demande a été envoyée à nos services.'
      end
   end
end 
