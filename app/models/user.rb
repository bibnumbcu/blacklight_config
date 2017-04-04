# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base

  if Blacklight::Utils.needs_attr_accessible?

    attr_accessible :email, :password, :password_confirmation
  end
# Connects this user object to Blacklights Bookmarks. 
  include Blacklight::User
  has_many :suggestion, dependent: :restrict
  attr_accessible :email, :password, :password_confirmation if Rails::VERSION::MAJOR < 4

# Connects this user object to Blacklights Bookmarks. 
  include Blacklight::User

  validates_uniqueness_of :user_id
  attr_accessible :user_id, :card_number, :name, :first_name, :email, :expir_date, :library, :address1, :address2,
   :phone1, :phone2, :birthday, :prets, :reservations, :communications, :remember_me, :suggestions

  attr_accessor :card_number,  :expir_date, :library, :address1, :address2,
   :phone1, :phone2, :birthday, :prets, :reservations, :communications, :remember_me

  @@messages = { 
               'COPIA_NO_RESERVABLE' => 'Cet exemplaire n\'est pas réservable.', 
               'COPIA_PRESTADA' => 'Cet exemplaire n\'est pas disponible pour le moment à la réservation.',
               'COPIA_NO_EXISTE' => 'Cet exemplaire n\'existe pas.',
               'COPIA_NO_EN_CIRCULACION' => 'Cet exemplaire est déjà réservé plusieurs fois.',
               'COPIA_NO_VALIDA' => 'Cet exemplaire n\'existe pas.',
               'LECTOR_ERROR' => 'Vous avez des prêts en retard et ne pouvez pas réserver cet exemplaire.',
               'LECTOR_CADUCADO' => 'Vous ne pouvez pas renouveler car vous avez dépassé la date de retour ou votre carte est momentanément suspendue.',
               'LECTOR_NO_EXISTE' => 'La demande de communication a été annulée en raison d\'une erreur sur le compte lecteur.',
               'LECTOR_SUSPENDIDO' => 'Votre carte est momentanément suspendue.',
               'TITULO_PRESTADO' => 'Vous ne pouvez pas réserver cet exemplaire.',
               'TITULO_RESERVADO' => 'Vous avez déjà réservé cet exemplaire.',
               'ADMIN_ERROR' => 'Une erreur s\'est produite. Veuillez contacter l\'administrateur.',
               'RESERVA_NO_EXISTE' => 'Cette réservation n\'a pas pu être annulée.',
               'RENOVACION_NO_AUTORIZADA' => 'Le renouvellement n\'est pas autorisé pour cet exemplaire.',
               'PETICION_NO_AUTORIZADA' => 'La demande de communication n\'est pas autorisée.',
                'LECTOR_PRESTAMOS_SOBRE' => 'Vous avez des prêts en retard et ne pouvez pas réserver cet exemplaire.'
  }

  #clé pour l'encodage/décodage du mot de passe
  cipher = OpenSSL::Cipher.new('aes-256-gcm')
  cipher.encrypt
  Iv = cipher.random_iv
  Salt = SecureRandom.random_bytes(16)
  Cle = Digest::SHA256.hexdigest('Pierre qui roule n\'amasse pas mousse.')
	Encryptor.default_options.merge!(insecure_mode: true, v2_gcm_iv: true)

  def password=(password)
      write_attribute(:password, Encryptor.encrypt(password, :key => Cle, :iv => Iv).force_encoding("ISO-8859-1").encode("UTF-8"))
  end
  
  def suggestions
      @suggestions = []
      Suggestion.where(user_id: read_attribute(:user_id)).each{|suggestion|
         next if suggestion.book_id.nil?
         book = Book.find(suggestion.book_id) 
         @suggestions << {
            :title => book.title,
            :author => book.author,
            :publisher => book.publisher,
            :isbn => book.isbn,
            :note => book.note,
            :pub_date => book.pub_date,
            :status => suggestion.status,
            :recipient => suggestion.recipient,
            :created_at => suggestion.created_at
         }
      }
      @suggestions
  end
  
  def assign_attributes(values, options = {})
    sanitize_for_mass_assignment(values, options[:as]).each do |k, v|
      send("#{k}=", v)
    end
  end
  
  def card_number
      User.get_card_number_from_user_id(read_attribute(:user_id))
  end
  
  def reservation exemplaire_id=nil
      connexion_zabnetarch = Zabnetarch.new
      return false if !connexion_zabnetarch.connect 
      reponse = connexion_zabnetarch.set_reservation( User.get_card_number_from_user_id(read_attribute(:user_id)), read_attribute(:password), exemplaire_id )
      connexion_zabnetarch.close
      
      return @@messages['ADMIN_ERROR'] if reponse.nil?
      return 'Votre réservation a été enregistrée'  if reponse==true
      @@messages[reponse]
  end
  
  def cancel_reservation exemplaire_id=nil
      connexion_zabnetarch = Zabnetarch.new 
      return false if !connexion_zabnetarch.connect
      reponse = connexion_zabnetarch.cancel_reservation( User.get_card_number_from_user_id(read_attribute(:user_id)), read_attribute(:password), exemplaire_id )
      connexion_zabnetarch.close
      
      return @@messages['ADMIN_ERROR'] if reponse.nil?
      return 'Cette réservation a été annulée.'  if reponse==true
      @@messages[reponse]
  end
  
  def renew_loan exemplaire_id=nil
#      Rails.logger.debug 'Bug051549 : carte : ' + read_attribute(:user_id)
      connexion_zabnetarch = Zabnetarch.new 
      return false if !connexion_zabnetarch.connect
      reponse = connexion_zabnetarch.renew_loan( User.get_card_number_from_user_id(read_attribute(:user_id)), read_attribute(:password), exemplaire_id )
      connexion_zabnetarch.close

      return @@messages['ADMIN_ERROR'] if reponse.nil?
      return 'Le renouvellement a été validé.'  if reponse==true
      @@messages[reponse]
  end
  
  def communication params=nil
      connexion_zabnetarch = Zabnetarch.new 
      return false if !connexion_zabnetarch.connect
      params[:name] = read_attribute(:name)
      params[:first_name] = read_attribute(:first_name)
      
      reponse = connexion_zabnetarch.communication( User.get_card_number_from_user_id(read_attribute(:user_id)), read_attribute(:password), params )
#      Rails.logger.debug 'Reponse 15h06 :  ' + reponse.inspect
      connexion_zabnetarch.close
      
      return @@messages['ADMIN_ERROR'] if reponse[:status].nil?
      return @@messages[reponse[:status]] if reponse[:status] != 'ok' 
      
      File.open('bulletin.txt', 'w') do |f2|  
        f2.puts reponse[:texte]
        # impression en deux fois pour faire un fantôme
        if params[:impression] == '2'
           f2.puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
           f2.puts reponse[:texte] 
        end
      end

      result = 'Le bulletin n\'a pas été envoyé. Une erreur s\'est produite'
      result = system("lp -d lafhpbdp \"bulletin.txt\"" ) if params[:impression] == '1'
      result = system("lp -d drtimp03 \"bulletin.txt\"" ) if params[:impression] == '2'
      result = system("lp -d hpcarnot \"bulletin.txt\"" ) if params[:impression] == '16'
#      result = system("lp -d HPTEST \"bulletin.txt\"" ) if params[:impression] == '2'
#      result = system("lp -d HPTEST \"bulletin.txt\"" ) if params[:impression] == '1'
#      result = system("lp -d HPTEST \"bulletin.txt\"" ) if params[:impression] == '16'
      return 'Le bulletin de demande a été envoyé' if result
#      return 'Le bulletin de demande a été envoyé' if system("lp", "bulletin.txt" )
  end
  
  
   
  #est-ce que l'utilisateur peut reserver ou faire une demande de communication pour cet exemplaire ( oui si il ne l'a pas déjà en emprunt )
  def get_this_book( barcode )
      return true if @prets.nil?
      emprunte = true
      @prets.each{ |un_pret|
         emprunte = false if un_pret['barcode'] == barcode
      }
      emprunte
   end
   
  #est-ce que l'utilisateur peut renouveler son prêt
  def renew_authorization ( barcode = '', nb_renouvellement='1')
      return false if ( nb_renouvellement >= '1' || @prets.nil? )
      libraries = ['1', '2', '4', '5', '6', '7', '9', '10','11', '12', '13', '16', '17', '18', '20', '21', '23', '24']
      renouvelle = false
      @prets.each{ |un_pret|
            renouvelle = true  if ( un_pret['barcode'] == barcode && libraries.include?( un_pret['succursale'] ) )
      }
      renouvelle
  end
   
  def self.clean_barcode (barcode='', succursale='2' )
      return barcode if barcode =~ /^\d{9}$/
      return '0' + barcode + '0' if barcode =~ /^\d{8}$/
      return '00' + barcode + '0' if barcode =~ /^\d{7}$/
      return '000' + barcode + '0' if barcode =~ /^\d{6}$/
      return '0000' + barcode + '0' if barcode =~ /^\d{5}$/
      return '00000' + barcode + '0' if barcode =~ /^\d{4}$/
      return '000000' + barcode + '0' if barcode =~ /^\d{3}$/
      return '0000000' + barcode + '0' if barcode =~ /^\d{2}$/
   end
   
  #renvoie un objet userbcu ou false pour indiquer si l'utilisateur est reconnu par zabnetarch
  def self.authenticate(login, password)
    connexion_zabnetarch = Zabnetarch.new
    return false if !connexion_zabnetarch.connect
    
    user = connexion_zabnetarch.get_lector(login, password) 
    connexion_zabnetarch.close
    user
  end
   
   def self.get_card_number_from_user_id user_id
      return 'L' + user_id   if user_id =~ /^\d{5,6}$/
      return '63' + user_id   if user_id =~ /^\d{9}$/
      user_id
   end
   
   # Method added by Blacklight; Blacklight uses #to_s on your
   # user class to get a user-displayable login/identifier for
   # the account. 
   def to_s
     read_attribute(:first_name) + ' ' + read_attribute(:name)
   end  
   
   def self.delete_guest_users
      self.destroy_all(:guest => true)
   end
   
   private
   def self.get_decrypted_password(password)  
      Encryptor.decrypt(password.encode("ISO-8859-1"), :key => Cle, :iv =>Iv)
   end
end
