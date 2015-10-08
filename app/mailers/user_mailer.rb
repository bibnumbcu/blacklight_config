class UserMailer < ActionMailer::Base
  default from: "ne-pas-repondre@clermont-universite.fr"
  helper :user
  
  def send_suggestion_to_recipient(user, book, recipient, email)
    @user = user
    @book = book
    @recipient = recipient
    @user_email = email
    to = "raphaele.bussemey@clermont-universite.fr"
#    to = "mathieu.bacault@clermont-universite.fr"
    mail(to: to, subject: 'Suggestion d\'achat')
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
