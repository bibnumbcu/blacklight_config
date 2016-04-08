# -*- encoding : utf-8 -*-

class Z3950
  attr_reader :ip, :base, :port, :url
  attr_accessor :keyword


   # port 2300 pour prod
   # port 2200 pour test
  def initialize(ip='192.168.120.249', base='abnet_db', port='2300')
      @ip = ip
      @base = base
      @port = port
      @url = @ip + ':' + @port + '/' + @base
   end
   
   def search
      resultats = ''
      tries = 0
      begin
#      Rails.logger.debug 'avant connexion 13h43' + url.inspect
         connexion = ZOOM::Connection.new()
         connexion.connect(url)
         rset = connexion.search(@keyword)
         rset.each_record do |record|
            resultats += record.xml if !record.xml.nil?
         end
         connexion.search('quit')
#         ZOOM::Connection.open(url) do |conn|
#            rset = conn.search(@keyword)
#            rset.each_record do |record|
#            resultats += record.xml
#            end
#            conn.search('quit')
#         end
#         Rails.logger.debug 'après connexion 13h23' + @keyword.inspect
         resultats.force_encoding("ISO-8859-1").encode("UTF-8")
      rescue RuntimeError
         tries += 1
         retry if tries < 3
#          Rails.logger.debug 'erreur connexion 13h44' + $!.inspect
         nil
      end
   
    
   end
   
   def get_localisations(reponseXML='', current_user=false)
      resultats = []
      begin   
         doc = REXML::Document.new(reponseXML)
      rescue
         return resultats 
      end    
      
      doc = REXML::Document.new(reponseXML)      
      root = doc.root      
      return resultats if !root.respond_to?('elements')
      
      #parcours des champs 998
      root.elements.each("datafield[@tag='998']") do |element|
         resultab = {}
         #pour chaque element fils on récupère les informations d'exemplaire (localisation, salle, cote, empruntable ou non, code barre)
         resultab[:empruntable] = true
         resultab[:localisation] = ''
         element.each do |field|
            next if !field.respond_to?('elements')
            resultab[:affichable] = field.elements["[@code='g']"].text.strip.downcase if !field.elements["[@code='g']"].nil?
            resultab[:localisation] = field.elements["[@code='b']"].text if !field.elements["[@code='b']"].nil?
            resultab[:salle] = field.elements["[@code='c']"].text if !field.elements["[@code='c']"].nil?
            resultab[:cote] = field.elements["[@code='e']"].text if !field.elements["[@code='e']"].nil?
            resultab[:cote_suppl] = field.elements["[@code='f']"].text if !field.elements["[@code='f']"].nil?
            resultab[:statut] = field.elements["[@code='d']"].text if !field.elements["[@code='d']"].nil?
            resultab[:barcode] =  field.elements["[@code='a']"].text if !field.elements["[@code='a']"].nil?
            resultab[:volume] =  field.elements["[@code='n']"].text if !field.elements["[@code='n']"].nil?
            resultab[:succursale] = field.elements["[@code='m']"].text if !field.elements["[@code='m']"].nil? 

#Rails.logger.debug 'Bug1649 : test : ' + field.elements["[@code='b']"].text.inspect
      
#           Rails.logger.debug 'Bug07101400 : test : ' + field.elements["[@code='h']"].nil?.inspect + ' ' + field.elements["[@code='l']"].nil?.inspect
            if !field.elements["[@code='h']"].nil? 
              resultab[:empruntable] = false if !field.elements["[@code='h']"].text.strip.empty?
            end
            if !field.elements["[@code='l']"].nil? 
               resultab[:empruntable] = false if !field.elements["[@code='l']"].text.strip.empty?
            end
            

            if !field.elements["[@code='i']"].nil?
               resultab[:date_retour] = nil
               resultab[:date_retour] = field.elements["[@code='i']"].text if !field.elements["[@code='i']"].text.strip.empty?
            end
         end 
         ###########################
         ## droits de reservation ##
         #est-ce que l'utilisateur a le droit de réserver
         resultab[:reservation] = false
         current_user_authorize = true  
         current_user_authorize =  current_user.get_this_book( resultab[:barcode] ) if  current_user
         authorized_library = true
         libraries = ['1', '2', '4', '5', '6', '9', '10', '11', '12', '13', '18', '20', '21', '24']
         authorized_library = false if ! libraries.include?( resultab[:succursale] )
         resultab[:reservation] =  true if ( ! resultab[:empruntable] && current_user_authorize && authorized_library )
         
         #nettoyage des données pour supprimer les espaces en trop
         resultab.each {|key, value| 
           value.strip! if value.respond_to?(:strip!)
         }
         ##############################
         ## droits de communications ##
         #1 : lafayette
         #6 : santé
         #16 : carnot
#         succursales = ['1', '6', '16']
         succursales = ['1', '16']
         salles_lafayette_excluded = ['ARCHIVES BASTAIRE', 'LAFAYETTE S. LECTURE', 'LAFAYET.S.CATALOGUES', 'LAF. S. PERIODIQUES']
#         salles_sante_authorized = ['MAGASIN : DEMANDER A L\'ACCUEIL']
         salles_carnot_excluded = ['SALLE A11']
         resultab[:impression] = '0'
         if resultab[:empruntable] && current_user_authorize && succursales.include?( resultab[:succursale] )
            resultab[:impression] = '1' if resultab[:succursale]=='1' && !salles_lafayette_excluded.include?( resultab[:salle] )
#            resultab[:impression] = '6' if resultab[:succursale]=='6' && salles_sante_authorized.include?( resultab[:salle] )
            resultab[:impression] = '16' if resultab[:succursale]=='16' && !salles_carnot_excluded.include?( resultab[:salle] )
         end
         resultab[:communication] = false
         resultab[:communication] = true if succursales.include?( resultab[:impression] )
         
          resultats << resultab if !resultab.empty?
      end
        
      resultats.sort { |a,b| 
         (a[:localisation] <=> b[:localisation]).nonzero? ||
         (b[:cote] <=> a[:cote])
      }
 end
end
