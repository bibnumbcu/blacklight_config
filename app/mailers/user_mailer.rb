class UserMailer < ActionMailer::Base
   
  default from: "bcu.contact@clermont-universite.fr"
  helper :user

  def send_suggestion_to_recipient(user, book, recipient, email, suggestion_id)
    @user = user
    @book = book
    @recipient = recipient
    @user_email = email
    @suggestion_id = suggestion_id
#    to = "raphaele.bussemey@clermont-universite.fr"
#    to = "mathieu.bacault@clermont-universite.fr"
   to = 'bcu.contact@clermont-universite.fr'
   
    subject = 'Suggestion d\'achat ' + ApplicationController.helpers.get_library_title(recipient)  
    mail(to: to, subject: subject )
  end
  
  def send_suggestion_to_lector(user, book, recipient, email)
    @user = user
    @book = book
    @recipient = recipient
#    to = "ne-pas-repondre@clermont-universite.fr"
    @email = email
    mail(to: @email, subject: 'Suggestion d\'achat')
  end
end
