# -*- encoding : utf-8 -*-
class Harvester
  attr_accessor :url, :name
   @@csv_separator = ';'
   @@multi_value_separator = ","
   @@dc_fields = [ 
            { :field_name => 'dc:title', :solr_field => 'title_display', :multivalued => false },
            { :field_name => 'dc:creator', :solr_field => 'author_display', :multivalued => true },
            { :field_name => 'dc:subject', :solr_field => 'subject_topic_display', :multivalued => true },
            { :field_name => 'dc:publisher', :solr_field => 'published_display', :multivalued => true },
            { :field_name => 'dc:contributor', :solr_field => 'edition_display', :multivalued => true },
#            { :field_name => 'dc:date', :solr_field => 'pub_date', :multivalued => true },
            { :field_name => 'dc:type', :solr_field => 'material_display', :multivalued => true },
            { :field_name => 'dc:format', :solr_field => 'format', :multivalued => false },
            { :field_name => 'dc:identifier', :solr_field => 'id', :multivalued => false },
            { :field_name => 'dc:source', :solr_field => 'edition_display', :multivalued => true },
            { :field_name => 'dc:language', :solr_field => 'language_facet', :multivalued => true },
            { :field_name => 'dc:coverage', :solr_field => 'subject_geo_facet', :multivalued => true },
            { :field_name => 'dc:rights', :solr_field => 'notes_display', :multivalued => true }
   ]
   
   
#  @@repositories_url = { 
#               'name' => 'Carnets Glangeaud',
#               'url' => 'http://bibliotheque.clermont-universite.fr/glangeaud/oai-pmh-repository/request'
#  }

#  def initialize name, url
#   @name = name
#   @url = url
#  end
  
  def self.harvest url,name
   client = OAI::Client.new url
   metadatas = []
   reponse = client.list_records
   p reponse.inspect
   token = reponse.resumption_token
   reponse.each{|identifier|
       #boucle sur chaque enregistrement
       identifier.metadata.each{ |data|
         if data.respond_to?('elements')
            line = ''
            @@dc_fields.each { |one_field|
               reponse = self.get_field data, one_field[:field_name], one_field[:multivalued]
               next if reponse.nil?
               line += reponse 
               line += @@csv_separator
#               p one_field[:field_name]
            }
#            p line
            metadatas << line
         end
       }
    }

############# TODO ############################################################################################
# * utiliser le jeton plutôt que de ramener tout l'entrepot d'un coup avec reponse.full.each
# * il y a un probleme de separateur de champ car le fichier csv resultant est impropre (lignes mal formées).
# * mettre en paramètre le choix d'une collection
###############################################################################################################

#    client.list_records(:resumption_token => token).each{|identifier|
#    #boucle sur chaque enregistrement
#    identifier.metadata.each{ |data|
#      if data.respond_to?('elements')
#         line = ''
#         @@dc_fields.each { |one_field|
#            line += self.get_field data, one_field['field_name'], one_field['multivalued']
#            line += @@csv_separator
#         }
#         metadatas << line
#      end
#    }
#   }

   header = ""
   @@dc_fields.each { |one_field|
      header += one_field[:solr_field]
      header += ';'
   }    
   
#   header = "id;title_display;format;published_display"
   file = "./tmp/moissonnage.csv"
   File.open(file, "w", {:col_sep => ";"}) do |csv|
     csv << header
     csv << "\n"
     metadatas.each { |one_line|
       csv << one_line
       csv << "\n"     
       # How puts line break here
       }
   end
  end
  
  
  def self.get_field root, field_name, multivalue=false
      one_value = []
      #boucle sur chaque element dublin core, ils peuvent être en double ou plus
      root.elements.each(field_name){ |element|
         one_value << element.text
      }
      return one_value[0] if !multivalue
      one_value.join(@@multi_value_separator)
  end
end
