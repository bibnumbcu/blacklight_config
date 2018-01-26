# -*- encoding : utf-8 -*-
class Harvester
  attr_accessor :url, :name, :set, :token, :reponse, :client, :writer
  @@dc_fields = [
            { :field_name => 'dc:title', :marc_field => '200a' },
            { :field_name => 'dc:description', :marc_field => '330a' },
            { :field_name => 'dc:creator', :marc_field => '700a' },
            { :field_name => 'dc:subject', :marc_field => '606a' },
            { :field_name => 'dc:publisher', :marc_field => '210c' },
            { :field_name => 'dc:contributor', :marc_field => '702a' },
            { :field_name => 'dc:date', :marc_field => '100a[8-16]' },
            { :field_name => 'dc:date', :marc_field => '210d' },
            { :field_name => 'dc:type', :marc_field => '230a' },
#            { :field_name => 'dc:format', :marc_field => '106a' },
            { :field_name => 'dc:identifier', :marc_field => '856u' },
            { :field_name => 'dc:relation', :marc_field => '856z' },
            { :field_name => 'dc:source', :marc_field => '910p' },
            { :field_name => 'dc:language', :marc_field => '101a' },
            { :field_name => 'dc:coverage', :marc_field => '607a' },
            { :field_name => 'dc:rights', :marc_field => '230a' }
   ]

  def initialize name, url, set
   @name = name
   @url = url
   @set = set
   @client = OAI::Client.new @url
   @writer = MARC::Writer.new('./tmp/moissonnage.mrc')
  end


  def harvest
   if @set.nil?
      reponse = @client.list_records()
   else
      reponse = @client.list_records(:set => @set)
   end
   token = reponse.resumption_token
   treat_answer reponse

   while !token.nil?
      reponse = @client.list_records(:resumption_token => token)
      treat_answer reponse
      token = reponse.resumption_token
   end

   @writer.close()
  end

  # parcours le xml issu de la reponse et génere le fichier marc
  def treat_answer reponse
   reponse.each{|identifier|
      record = MARC::Record.new()
      #données pour le format "Documents numérisés" et le type de document
      record.leader[6] = 'n'
      record.leader[7] = 'm'
      record << MARC::ControlField.new('001', identifier.header.identifier.gsub('.', ''))
      @@dc_fields.each { |dc_field|
         identifier.metadata.elements.each('oai_dc:dc/'+dc_field[:field_name]){ |element|
            if dc_field[:field_name]=='dc:creator' || dc_field[:field_name]=='dc:creator'
              text = element.text.split(',').join(" ")  
            else
              text = element.text
            end
            text = @name if dc_field[:field_name] == 'dc:source'
#            text = 's' if dc_field[:field_name] == 'dc:format'
            record << MARC::DataField.new(dc_field[:marc_field][0..2], '0', '0', [dc_field[:marc_field][3], text])
            break if dc_field[:field_name] == 'dc:title'
         }
      }
#     p record
      record.to_marc
      @writer.write(record)
   }
  end
end
