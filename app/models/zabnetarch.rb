# -*- encoding : utf-8 -*-
require 'rexml/document'
class Zabnetarch
  attr_reader :ip, :port
  attr_accessor :socket

    # port 5211 pour prod
    # port 5212 pour test
   def initialize(ip='192.168.120.249', port='5211')
      @ip = ip
      @port = port
   end


   #détermine si les identifiants en paramètres correspondent à un lecteur
   def get_lector(login, password)
      login = User.get_card_number_from_user_id(login)
      query='LECTOR|' + login.capitalize + '|' + password
      send query
      responseXML = get_response

      #traitement des caractères mal formés de la réponse (& au lieu de &amp; par exemple)
      responseXML = responseXML.gsub(/&/, '&amp;')
#      Rails.logger.debug 'BUG512 : reponse : ' + responseXML.inspect
      doc = REXML::Document.new(responseXML)
      rootXML = doc.root
      return false if rootXML.nil?
      lector_exist_error = rootXML.elements["fault/value"]
      lector_exist_ok = rootXML.elements["DLECTOR/lector/lenlec"]

      return false if !lector_exist_error.nil?
      return false if lector_exist_ok.nil?

      #récupération des données lecteur
      user_datas = {}
      user_datas[:user_id] = rootXML.elements["DLECTOR/lector/lenlec"].text if !rootXML.elements["DLECTOR/lector/lenlec"].nil?
      #user_datas[:card_number] = login
      user_datas[:email] = rootXML.elements["DLECTOR/lector/lemail"].text if !rootXML.elements["DLECTOR/lector/lemail"].nil?
      user_datas[:name] = rootXML.elements["DLECTOR/lector/leapel"].text if !rootXML.elements["DLECTOR/lector/leapel"].nil?
      user_datas[:first_name] = rootXML.elements["DLECTOR/lector/lenomb"].text if !rootXML.elements["DLECTOR/lector/lenomb"].nil?
      user_datas[:expir_date] = rootXML.elements["DLECTOR/lector/lefcad"].text if !rootXML.elements["DLECTOR/lector/lefcad"].nil?
      user_datas[:library] = rootXML.elements["DLECTOR/lector/lecobi"].text if !rootXML.elements["DLECTOR/lector/lecobi"].nil?

      user_datas[:address1] = ''
      user_datas[:address1] = rootXML.elements["DLECTOR/lector/ledi11"].text if !rootXML.elements["DLECTOR/lector/ledi11"].text.nil?
      user_datas[:address1] += ' ' + rootXML.elements["DLECTOR/lector/ledi12"].text if !rootXML.elements["DLECTOR/lector/ledi12"].text.nil?
      user_datas[:address1] += ' ' + rootXML.elements["DLECTOR/lector/ledi13"].text if !rootXML.elements["DLECTOR/lector/ledi13"].text.nil?

      user_datas[:address2] = ''
      user_datas[:address2] = rootXML.elements["DLECTOR/lector/ledi21"].text if !rootXML.elements["DLECTOR/lector/ledi21"].text.nil?
      user_datas[:address2] += ' ' + rootXML.elements["DLECTOR/lector/ledi22"].text if !rootXML.elements["DLECTOR/lector/ledi22"].text.nil?
      user_datas[:address2] += ' ' + rootXML.elements["DLECTOR/lector/ledi23"].text if !rootXML.elements["DLECTOR/lector/ledi23"].text.nil?


      user_datas[:phone1] = rootXML.elements["DLECTOR/lector/letfn1"].text if !rootXML.elements["DLECTOR/lector/letfn1"].nil?
      user_datas[:phone2] = rootXML.elements["DLECTOR/lector/letfn2"].text if !rootXML.elements["DLECTOR/lector/letfn2"].nil?
      user_datas[:birthday] = rootXML.elements["DLECTOR/lector/lefnac"].text if !rootXML.elements["DLECTOR/lector/lefnac"].nil?

      #récupération des données de prêt
      attributes = [
               {:label => 'titn', :field => 'tintit'},
               {:label => 'succursale', :field => 'prcosu'},
               {:label => 'titre', :field => 'tititu'},
               {:label => 'date_retour', :field => 'prfdev'},
               {:label => 'date_pret', :field => 'prfpre'},
               {:label => 'nb_renouvellement', :field => 'prnren'},
               {:label => 'barcode', :field => 'prbarc'}
               ]
      prets = get_XML_fields(rootXML, "DLECTOR/PRESTAMOS/presta", attributes)


      #récupération des réservations
      attributes = [
               {:label => 'titn', :field => 'rentit'},
               {:label => 'succursale', :field => 'recosu'},
               {:label => 'titre', :field => 'tititu'},
               {:label => 'date_echeance', :field => 'reffin'},
               {:label => 'priorite', :field => 'reprio'},
               {:label => 'barcode', :field => 'rebarc'}
               ]
      reservations = get_XML_fields(rootXML, "DLECTOR/RESERVAS/reserv", attributes)

      #récupération des demandes de communications
      attributes = [
               {:label => 'titn', :field => 'tintit'},
               {:label => 'succursale', :field => 'prcosu'},
               {:label => 'titre', :field => 'tititu'},
               {:label => 'banque_emprunt', :field => 'prcomp'},
               {:label => 'etat', :field => 'prcopt'}
               ]
      communications = get_XML_fields(rootXML, "DLECTOR/PETICION/presta", attributes)

      attributes = {
         #:user_id => user_datas[:user_id],
         :card_number => login,
         :name => user_datas[:name],
         :first_name => user_datas[:first_name],
         :email => user_datas[:email],
         :expir_date => user_datas[:expir_date],
         :library => user_datas[:library],
         :address1 => user_datas[:address1],
         :address2 => user_datas[:address2],
         :phone1 => user_datas[:phone1],
         :phone2 => user_datas[:phone2],
         :birthday => user_datas[:birthday],
         :prets => prets,
         :reservations => reservations,
         :communications => communications
      }

      user = User.where(:user_id =>  user_datas[:user_id]).first_or_initialize
      user.password = password
      user.name = attributes[:name]
      user.first_name = attributes[:first_name]
      user.email = attributes[:email]
      user.save
      user.assign_attributes(attributes)
      return user
   end

   #traite la réponse xml de zabnetarch
   def get_XML_fields(root, root_name, attributes)
      xml_fields = []
      root.elements.each(root_name) do |field|
                  one_line = {}
                  attributes.each do |one_attr|
                     one_line[one_attr[:label]] = field.elements[one_attr[:field]].text if !field.elements[one_attr[:field]].nil?
                  end
                  xml_fields << one_line
      end
      xml_fields
   end

   def set_reservation (login, password, barcode=nil)
      query='RESERVAR|' + login + '|' + User.get_decrypted_password(password) + '|' + barcode
      send query
      responseXML = get_response

      doc = REXML::Document.new(responseXML)
      rootXML = doc.root

      reservation_response_error = rootXML.elements["fault/value"]
      reservation_reponse_ok = rootXML.elements["reserv/rebarc"]
#      Rails.logger.debug 'BUG512 : reponse : ' + reservation_response_error.text.inspect
      return reservation_response_error.text if !reservation_response_error.nil?
      return true if !reservation_reponse_ok.nil?
   end

   def cancel_reservation (login, password, barcode='')
      query='ANULAR_RESERVA|' + login + '|' + User.get_decrypted_password(password) + '|' + barcode
      send query
      responseXML = get_response

      doc = REXML::Document.new(responseXML)
      rootXML = doc.root

      cancel_response_error = rootXML.elements["fault/value"]
      cancel_reponse_ok = rootXML.elements["params/value"]
#    Rails.logger.debug 'BUG04091227 : reponse : ' + cancel_response_error.text.inspect
      return cancel_response_error.text if !cancel_response_error.nil?
      return true if !cancel_reponse_ok.nil?
   end

   def renew_loan (login, password, barcode='')
      query='RENOVAR_PRESTAMO|' + login + '|' + User.get_decrypted_password(password) + '|' + barcode
      send query
      responseXML = get_response

      doc = REXML::Document.new(responseXML)
      rootXML = doc.root

      renew_response_error = rootXML.elements["fault/value"]
      renew_reponse_ok = rootXML.elements["presta/prbarc"]
#    Rails.logger.debug 'BUG04091408 : reponse : ' + renew_response_error.text.inspect
      return renew_response_error.text if !renew_response_error.nil?
      return true if !renew_reponse_ok.nil?
   end


   #demande qui lance l'impression d'un bulletin.
   def communication (login, password, params=nil)
#      query='PETICION|' + login + '|' + User.get_decrypted_password(password) + '|' + params[:barcode] + '|' + '1'
      query='PETICION|' + login + '|' + User.get_decrypted_password(password) + '|' + params[:barcode] + '|' + params[:impression]
      send query
      responseXML = get_response

      doc = REXML::Document.new(responseXML)
      rootXML = doc.root

#      Rails.logger.debug 'BUG-zabnetarch communication 15h10 : reponse : ' + responseXML.inspect

      response = {}
      response[:status] = rootXML.elements["fault/value"].text if !rootXML.elements["fault/value"].nil?
      if !rootXML.elements["presta/prbarc"].nil?
         response[:status] = 'ok'
         code_lecteur = rootXML.elements["presta/prnlec"].text if !rootXML.elements["presta/prnlec"].nil?
         date = rootXML.elements["presta/prfpre"].text if !rootXML.elements["presta/prfpre"].nil?
         succursale = rootXML.elements["presta/prcosu"].text if !rootXML.elements["presta/prcosu"].nil?
         localisation = rootXML.elements["presta/prcocl"].text if !rootXML.elements["presta/prcocl"].nil?
         titre = rootXML.elements["presta/tititu"].text if !rootXML.elements["presta/tititu"].nil?
         response[:texte] = ""
         response[:texte] +=  params[:lieu] + "\n" if !params[:lieu].nil?
         response[:texte] += "Nom : \t\t\t" + params[:name] + "\n" if !params[:name].nil?
         response[:texte] += "Prénom : \t\t" + params[:first_name] + "\n" if !params[:first_name].nil?
         response[:texte] += "Code lecteur : \t\t" + code_lecteur + "\n" if !code_lecteur.nil?
         response[:texte] += "Date : \t\t\t" + date + "\n\n" if !date.nil?
         response[:texte] += "Succursale : \t\t" + succursale + "\n" if !succursale.nil?
         response[:texte] += "Localisation : \t\t" + localisation + "\n\n" if !localisation.nil?
         response[:texte] += "Cote : \t\t\t" + params[:cote] + "\n" if !params[:cote].nil?
         response[:texte] += "Cote supplémentaire : \t\t" + params[:cote_suppl] + "\n\n" if !params[:cote_suppl].nil?
         response[:texte] += "Code barre : \t\t" + params[:barcode] + "\n" if !params[:barcode].nil?
         response[:texte] += "Titre : \t\t" + titre  if !titre.nil?
      end
      response
   end


   def connect
      begin
         @socket = TCPSocket.open(@ip, @port)
      rescue
         return false
      else
         return true
      end
   end

   def send(query='')
      if @socket.respond_to?('puts')
         @socket.puts('START|admin_bl|Acvr1d!I')
         @socket.puts(query)
         @socket.puts('END|')
         @socket.puts('END|')
         @socket.puts('END|')
      end
   end

   #récupère la reponse xml de zabnetarch
   def get_response
      return nil if ! @socket.respond_to?('gets')
      all_data = []
#      while line = socket.gets
#         all_data << $_
#      end

#-----------------------------------------------------------------------
# modification pour AbsysNet 2.0
#-----------------------------------------------------------------------

	i = 0
	compteur = 0

	loop do
	   # on recupere le contenu xml
	   all_data[i] = socket.gets
	   # on teste pour voir si il affiche methodResponse si il affiche compteur+1
	   if (all_data[i] =~ /\/methodResponse(.*)/ )
	      compteur = compteur + 1
	   end

	   break if (compteur == 2)
	   i = i+1
	end


#-----------------------------------------------------------------------

      #on supprime la première réponse indiquant le succès de la connexion.
      for i in 0..3
         all_data.shift i
      end
      return all_data.join.force_encoding("ISO-8859-1").encode("UTF-8")
   end

   def close
      return false if !@socket.respond_to?('close')
      @socket.close
   end
end
