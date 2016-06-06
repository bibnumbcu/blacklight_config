# -*- encoding : utf-8 -*-
module ApplicationHelper

  
   def date_in_french date=nil
      return nil if date.nil? 
      parts = date.split('-')
      year = parts[0].to_i
      month = parts[1].to_i
      day = parts[2].split(' ')[0].to_i
      I18n.localize( Date.new( year, month, day  ), :format => :long) # using short format
   end
   
###  
#helpers pour l'affichage de différents champs.
###
    def solrmarc_separator
      ' ,, '
    end 
    

    def helper_description_method args
      field = args[:document][args[:field]]
      result = ''
      field.each{ |one_line|
        one_line = one_line.gsub(/^br\.|br$/i,"Broché") if !one_line.nil?
        one_line = one_line.gsub(/^rel\.|rel$/i,"Relié") if !one_line.nil?
        result += one_line + '<br />'
      }
      raw result
    end
    
    def helper_multiligne_method args
      field = args[:document][args[:field]]
      result = ''
      field.each{ |one_line|
         result += one_line + '<br />' if !one_line.nil?
      }
      raw result
    end
    
    def helper_theme_method args
      field = args[:document][args[:field]]
      result = ''
      field.each{ |one_line|
         link = ''
         chaine =''
         search_keyword = ''
         parts = one_line.split(solrmarc_separator)
         parts.each_with_index{ |part, index|            
               search_keyword += CGI::escape(part)
               search_keyword += ', ' if (index < parts.length-1)
               chaine += '<a href="/?q=' + search_keyword + '&search_field=subject&commit=Chercher">' + part + '</a>' 
               chaine += ', ' if (index < parts.length-1)
            }
         result += chaine + '<br />'
      }
     raw result
  end
  
  def helper_author_method args
      field = args[:document][args[:field]]
      result = ''
      return raw result if field.nil?
      field.each{ |one_line|
         author_name =  one_line.split(',').first
         function = one_line.split(',')[-1]
         function='' if function==author_name 
         function = ', ' + function if function != ''
         result += '<a href="/?q='+ author_name + '&search_field=auteur&commit=Chercher">' + author_name + '</a>' + function + '<br />' if !author_name.nil?
      }
      raw result
  end
  
  def helper_title_series_method args
      field = args[:document][args[:field]]
      result = ''
      field.each{ |one_line|
         result += '<a href="/?qt=advanced&q=title_series_t:'+ one_line + '">' + one_line + '</a>' + '<br />' if !one_line.nil?
      }
      raw result
  end
  
  def helper_url_fulltext_method args
      field = args[:document][args[:field]]
      result = ''
      proxy = 'http://sicd.clermont-universite.fr/login?url='
      field.each{ |one_line|
         if one_line =~ /^http:\/\/www\.numilog\.com/
            one_line = proxy + one_line 
            result += '<a href="' + one_line + '">' + 'Disponible en ligne' + '</a>' + '<br />' if !one_line.nil?
         end
         if one_line =~ /^http:\/\/bibliotheque-virtuelle\.clermont-universite\.fr\/items\/show/ 
            result += '<a href="' + one_line + '">' + one_line + '</a>' + '<br />' if !one_line.nil?
         end
#         result += '<a href="' + one_line + '">' + one_line + '</a>' + '<br />' if !one_line.nil?
      }
   
      return 'Aucun lien pour ce document' if result==''
      raw result
  end
  
  def helper_revue_parente_method args
      field = args[:document][args[:field]]
      if !field[0].nil? && !field[1].nil?
#         return raw '<a href="/?f[format][]=Revue&qt=advanced&q=issn_t:' + field[1] + '">' + field[0] + '</a>' + '<br />'
          return raw '<a href="/?f[format][]=Revue&q=' + field[1] + '">' + field[0] + '</a>' + '<br />'
      end
      field
  end
  
  def helper_champ400_method args
      field = args[:document][args[:field]]
      result = ''
      field.each{ |one_line|
         if !one_line.nil?
           issn =  one_line[/.{4}-.{4}$/i]
#           result += '<a href="/?qt=advanced&q=issn_t:' + issn +'">' + one_line + '</a><br />' if !issn.nil?
           result += '<a href="/?q=' + issn +'">' + one_line + '</a><br />' if !issn.nil?
         end
      }
      return field if result.empty?
      return  raw result
  end
  
  def helper_notes_method args
      field = args[:document][args[:field]]
      result = ''
      field.each{ |one_line|
         result += one_line + ' <br />' if !one_line.nil?
      }
      
      words = result.split(" ")
      result= ''
      words.each{|one_word|
         result += ' '
         if one_word =~ /^http:\/\/*/
            result += '<a href="' + one_word + '">' + one_word + '</a>'
         else
            result += one_word
         end
      }
      
      if ( words.length > 50 )
         result = '<span class="resume">'
         result += words.first(50).join(" ")
         result += '</span> <span class="more">'
         result += words.last(words.length-50).join(" ")
         result += '</span>'
      end
      raw result
  end
  
  def helper_vignette_method args
      vignette = args[:document][args[:field]]
      if  vignette[0] =~ /^vignette : http:\/\//
         result = '<img src="'+ vignette[0][11..vignette[0].length] +'"/>'
         return raw result
      end
      return raw vignette
  end
end
