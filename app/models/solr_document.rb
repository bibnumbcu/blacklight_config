# -*- encoding : utf-8 -*-
class SolrDocument 

  include Blacklight::Solr::Document    
      # The following shows how to setup this blacklight document to display marc documents
  extension_parameters[:marc_source_field] = :marc_display
  extension_parameters[:marc_format_type] = :marcxml
  use_extension( Blacklight::Solr::Document::Marc) do |document|
    document.key?( :marc_display  )
  end
  
  field_semantics.merge!(    
                         :title => "title_display",
                         :author => "author_display",
                         :language => "language_facet",
                         :format => "format"
                         )



  # self.unique_key = 'id'
  
  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Email )
  
  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Sms )

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension( Blacklight::Solr::Document::DublinCore)    

module SolrDocument::Unimarc
     def localisations
      connexion_z3950 = Z3950.new
      connexion_z3950.keyword = '@attr 1=52 ' + id
      resultats = connexion_z3950.search
      localisations = connexion_z3950.get_localisations(resultats)
     end
     
     # Exports as an OpenURL KEV (key-encoded value) query string.
     # For use to create COinS, among other things. COinS are
     # for Zotero, among other things. TODO: This is wierd and fragile
     # code, it should use ruby OpenURL gem instead to work a lot
     # more sensibly. The "format" argument was in the old marc.marc.to_zotero
     # call, but didn't neccesarily do what it thought it did anyway. Left in
     # for now for backwards compatibilty, but should be replaced by
     # just ruby OpenURL. 
     def export_as_openurl_ctx_kev(format = nil)  
       title = to_marc.find{|field| field.tag == '200'}
       author = to_marc.find{|field| field.tag == '700'}
       corp_author = to_marc.find{|field| field.tag == '701'}
       publisher_info = to_marc.find{|field| field.tag == '210'}
       edition = to_marc.find{|field| field.tag == '205'}
       isbn = to_marc.find{|field| field.tag == '010'}
       issn = to_marc.find{|field| field.tag == '011'}
       unless format.nil?
         format.is_a?(Array) ? format = format[0].downcase.strip : format = format.downcase.strip
       end
         export_text = ""
         
         if (format =~ /livre/i)
           export_text << "ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook&rfr_id=info%3Asid%2Fblacklight.rubyforge.org%3Agenerator&rft.genre=book&"
           export_text << "rft.btitle=#{(title.nil? or title['a'].nil?) ? "" : CGI::escape(title['a'])}+#{(title.nil? or title['e'].nil?) ? "" : CGI::escape(title['e'])}&"
           export_text << "rft.title=#{(title.nil? or title['a'].nil?) ? "" : CGI::escape(title['a'])}+#{(title.nil? or title['e'].nil?) ? "" : CGI::escape(title['e'])}&"
           export_text << "rft.au=#{CGI::escape(author['b']) if author['b']}+#{CGI::escape(author['a']) if author['a']}&" unless author.blank?
           export_text << "rft.aucorp=#{CGI::escape(corp_author['b']) if corp_author['b']}+#{CGI::escape(corp_author['a']) if corp_author['a']}&" unless corp_author.blank?
           export_text << "rft.date=#{(publisher_info.nil? or publisher_info['d'].nil?) ? "" : CGI::escape(publisher_info['d'])}&"
           export_text << "rft.place=#{(publisher_info.nil? or publisher_info['a'].nil?) ? "" : CGI::escape(publisher_info['a'])}&"
           export_text << "rft.pub=#{(publisher_info.nil? or publisher_info['c'].nil?) ? "" : CGI::escape(publisher_info['c'])}&"
           export_text << "rft.edition=#{(edition.nil? or edition['a'].nil?) ? "" : CGI::escape(edition['a'])}&"
           export_text << "rft.isbn=#{(isbn.nil? or isbn['a'].nil?) ? "" : isbn['a']}"
         elsif (format =~ /article/i) # checking using include because institutions may use formats like Journal or Journal/Magazine
           export_text << "ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rfr_id=info%3Asid%2Fblacklight.rubyforge.org%3Agenerator&rft.genre=article&"
           export_text << "rft.title=#{(title.nil? or title['a'].nil?) ? "" : CGI::escape(title['a'])}+#{(title.nil? or title['e'].nil?) ? "" : CGI::escape(title['e'])}&"
           export_text << "rft.atitle=#{(title.nil? or title['a'].nil?) ? "" : CGI::escape(title['a'])}+#{(title.nil? or title['e'].nil?) ? "" : CGI::escape(title['e'])}&"
           export_text << "rft.aucorp=#{CGI::escape(author['b']) if author['b']}+#{CGI::escape(author['a']) if author['a']}&" unless author.blank?
           export_text << "rft.date=#{(publisher_info.nil? or publisher_info['d'].nil?) ? "" : CGI::escape(publisher_info['d'])}&"
           export_text << "rft.issn=#{(issn.nil? or issn['a'].nil?) ? "" : issn['a']}"
         else
            export_text << "ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc&rfr_id=info%3Asid%2Fblacklight.rubyforge.org%3Agenerator&"
            export_text << "rft.title=" + ((title.nil? or title['a'].nil?) ? "" : CGI::escape(title['a']))
            export_text <<  ((title.nil? or title['e'].nil?) ? "" : CGI.escape(" ") + CGI::escape(title['e']))
            export_text << "&rft.creator=#{CGI::escape(author['b']) if author['b']}+#{CGI::escape(author['a']) if author['a']}" unless author.blank?
            export_text << "&rft.aucorp=#{CGI::escape(corp_author['b']) if corp_author['b']}+#{CGI::escape(corp_author['a']) if corp_author['a']}" unless corp_author.blank?
            export_text << "&rft.date=" + ((publisher_info.nil? or publisher_info['d'].nil?) ? "" : CGI::escape(publisher_info['d']))
            export_text << "&rft.place=" + ((publisher_info.nil? or publisher_info['a'].nil?) ? "" : CGI::escape(publisher_info['a']))
            export_text << "&rft.pub=" + ((publisher_info.nil? or publisher_info['c'].nil?) ? "" : CGI::escape(publisher_info['c']))
            export_text << "&rft.format=" + (format.nil? ? "" : CGI::escape(format))
        end
        export_text unless export_text.blank?
     end


     # This format used to be called 'refworks', which wasn't really
     # accurate, sounds more like 'refworks tagged format'. Which this
     # is not, it's instead some weird under-documented Refworks 
     # proprietary marc-ish in text/plain format. See
     # http://robotlibrarian.billdueber.com/sending-marcish-data-to-refworks/
     def export_as_refworks_marc_txt
       # plugin/gem weirdness means we do need to manually require
       # here.
       # As of 11 May 2010, Refworks has a problem with UTF-8 if it's decomposed,
       # it seems to want C form normalization, although RefWorks support
       # couldn't tell me that. -jrochkind
       # DHF: moved this require a little lower in the method.
       # require 'unicode'    
     
       fields = to_marc.find_all { |f| ('000'..'999') === f.tag }
       text = "LEADER #{to_marc.leader}"
       fields.each do |field|
       unless ["940","999"].include?(field.tag)
         if field.is_a?(MARC::ControlField)
           text << "#{field.tag}    #{field.value}\n"
         else
           text << "#{field.tag} "
           text << (field.indicator1 ? field.indicator1 : " ")
           text << (field.indicator2 ? field.indicator2 : " ")
           text << " "
             field.each {|s| s.code == 'a' ? text << "#{s.value}" : text << " |#{s.code}#{s.value}"}
           text << "\n"
          end
           end
       end

       if Blacklight.jruby? 
         require 'java'
         java_import java.text.Normalizer
         Normalizer.normalize(text, Normalizer::Form::NFC).to_s
       else 
         require 'unicode'
         Unicode.normalize_C(text)
       end
     end 

     # Endnote Import Format. See the EndNote User Guide at:
     # http://www.endnote.com/support/enx3man-terms-win.asp
     # Chapter 7: Importing Reference Data into EndNote / Creating a Tagged “EndNote Import” File
     #
     # Note: This code is copied from what used to be in the previous version
     # in ApplicationHelper#render_to_endnote.  It does NOT produce very good
     # endnote import format; the %0 is likely to be entirely illegal, the
     # rest of the data is barely correct but messy. TODO, a new version of this,
     # or better yet just an export_as_ris instead, which will be more general
     # purpose. 
     def export_as_endnote()
       end_note_format = {
         "%A" => "700.b,700.a",
         "%C" => "210.a",
         "%D" => "210.d",
         "%E" => "702.b,702.a",
         "%I" => "210.c",
         "%J" => "225.a",
         "%@" => "010.a",
         "%_@" => "011.a",
         "%T" => "200.a,200.e",
         "%U" => "856.u",
         "%7" => "205.a"
       }
       marc_obj = to_marc

       # TODO. This should be rewritten to guess
       # from actual Marc instead, probably.
       format_str = 'Generic'
       
       text = ''
       text << "%0 #{ format_str }\n"
       # If there is some reliable way of getting the language of a record we can add it here
       #text << "%G #{record['language'].first}\n"
       end_note_format.each do |key,value|
         values = value.split(",")
         first_value = values[0].split('.')
         if values.length > 1
           second_value = values[1].split('.')
         else
           second_value = []
         end
         
         if marc_obj[first_value[0].to_s]
           marc_obj.find_all{|f| (first_value[0].to_s) === f.tag}.each do |field|
             if field[first_value[1]].to_s or field[second_value[1]].to_s
               text << "#{key.gsub('_','')}"
               if field[first_value[1]].to_s
                 text << " #{field[first_value[1]].to_s}"
               end
               if field[second_value[1]].to_s
                 text << " #{field[second_value[1]].to_s}"
               end
               text << "\n"
             end
           end
         end
       end
       text
     end

     protected
     
     # Main method for defining chicago style citation.  If we don't end up converting to using a citation formatting service
     # we should make this receive a semantic document and not MARC so we can use this with other formats.
     def chicago_citation(marc)
       authors = get_all_authors(marc)    
       author_text = ""
       unless authors[:primary_authors].blank?
         if authors[:primary_authors].length > 10
           authors[:primary_authors].each_with_index do |author,index|
             if index < 7
               if index == 0
                 author_text << "#{author}"
                 if author.ends_with?(",")
                   author_text << " "
                 else
                   author_text << ", "
                 end
               else
                 author_text << "#{name_reverse(author)}, "
               end
             end
           end
           author_text << " et al."
         elsif authors[:primary_authors].length > 1
           authors[:primary_authors].each_with_index do |author,index|
             if index == 0
               author_text << "#{author}"
               if author.ends_with?(",")
                 author_text << " "
               else
                 author_text << ", "
               end
             elsif index + 1 == authors[:primary_authors].length
               author_text << "et #{name_reverse(author)}."
             else
               author_text << "#{name_reverse(author)}, "
             end 
           end
         else
           author_text << authors[:primary_authors].first
         end
       else
         temp_authors = []
         authors[:translators].each do |translator|
           temp_authors << [translator, "trad."]
         end
         authors[:editors].each do |editor|
           temp_authors << [editor, "ed."]
         end
         authors[:compilers].each do |compiler|
           temp_authors << [compiler, "dir."]
         end
         
         unless temp_authors.blank?
           if temp_authors.length > 10
             temp_authors.each_with_index do |author,index|
               if index < 7
                 author_text << "#{author.first} #{author.last} "
               end
             end
             author_text << " et al."
           elsif temp_authors.length > 1
             temp_authors.each_with_index do |author,index|
               if index == 0
                 author_text << "#{author.first} #{author.last}, "
               elsif index + 1 == temp_authors.length
                 author_text << "et #{name_reverse(author.first)} #{author.last}"
               else
                 author_text << "#{name_reverse(author.first)} #{author.last}, "
               end
             end
           else
             author_text << "#{temp_authors.first.first} #{temp_authors.first.last}"
           end
         end
       end
       title = ""
       additional_title = ""
       section_title = ""
       if marc["200"] and (marc["200"]["a"] or marc["200"]["e"])
         title << citation_title(clean_end_punctuation(marc["200"]["a"]).strip) if marc["200"]["a"]
         title << ": #{citation_title(clean_end_punctuation(marc["200"]["e"]).strip)}" if marc["200"]["e"]
       end
       if marc["200"] and (marc["200"]["h"] or marc["200"]["i"])
         section_title << citation_title(clean_end_punctuation(marc["200"]["h"])) if marc["200"]["h"]
         if marc["200"]["i"]
           section_title << ", <i>#{citation_title(clean_end_punctuation(marc["200"]["i"]))}.</i>"
         elsif marc["200"]["h"]
           section_title << "."
         end
       end
       
       if !authors[:primary_authors].blank? and (!authors[:translators].blank? or !authors[:editors].blank? or !authors[:compilers].blank?)
           additional_title << "Traduit par #{authors[:translators].collect{|name| name_reverse(name)}.join(" et ")}. " unless authors[:translators].blank?
           additional_title << "Edité par #{authors[:editors].collect{|name| name_reverse(name)}.join(" et ")}. " unless authors[:editors].blank?
           additional_title << "Sous la direction de #{authors[:compilers].collect{|name| name_reverse(name)}.join(" et ")}. " unless authors[:compilers].blank?
       end
       
       edition = ""
       edition << setup_edition(marc) unless setup_edition(marc).nil?
       
       pub_info = ""
       if marc["210"] and (marc["210"]["a"] or marc["210"]["c"]) 
         pub_info << clean_end_punctuation(marc["210"]["a"]).strip if marc["210"]["a"]
         pub_info << ": #{clean_end_punctuation(marc["210"]["c"]).strip}" if marc["210"]["c"]
         pub_info << ", #{setup_pub_date(marc)}" if marc["210"]["d"]
       elsif marc["328"] and marc["328"]["a"] # MARC 502 is the Dissertation Note.  This holds the correct pub info for these types of records.
         pub_info << marc["328"]["a"]
       elsif marc["328"] and (marc["328"]["b"] or marc["328"]["c"] or marc["328"]["d"]) #sometimes the dissertation note is encoded in pieces in the $b $c and $d sub fields instead of lumped into the $a
         pub_info << "#{marc["328"]["b"]}, #{marc["328"]["c"]}, #{clean_end_punctuation(marc["328"]["d"])}"
       end
       
       citation = ""
       citation << "#{author_text} " unless author_text.blank?
       citation << "<i>#{title}.</i> " unless title.blank?
       citation << "#{section_title} " unless section_title.blank?
       citation << "#{additional_title} " unless additional_title.blank?
       citation << "#{edition} " unless edition.blank?
       citation << "#{pub_info}." unless pub_info.blank?
       citation
     end
     
     
     
     def mla_citation(record)
       text = ''
       authors_final = []
       
       #setup formatted author list
       authors = get_author_list(record)

       if authors.length < 4
         authors.each do |l|
           if l == authors.first #first
             authors_final.push(l)
           elsif l == authors.last #last
             authors_final.push(", et " + name_reverse(l) + ".")
           else #all others
             authors_final.push(", " + name_reverse(l))
           end
         end
         text += authors_final.join
         unless text.blank?
           if text[-1,1] != "."
             text += ". "
           else
             text += " "
           end
         end
       else
         text += authors.first + ", et al. "
       end
       # setup title
       title = setup_title_info(record)
       if !title.nil?
         text += "<i>" + mla_citation_title(title) + "</i> "
       end

       # Edition
       edition_data = setup_edition(record)
       text += edition_data + " " unless edition_data.nil?
       
       # Publication
       text += setup_pub_info(record) + ", " unless setup_pub_info(record).nil?
       
       # Get Pub Date
       text += setup_pub_date(record) unless setup_pub_date(record).nil?
       if text[-1,1] != "."
         text += "." unless text.nil? or text.blank?
       end
       text
     end

     def apa_citation(record)
       text = ''
       authors_list = []
       authors_list_final = []
       
       #setup formatted author list
       authors = get_author_list(record)
       authors.each do |l|
         authors_list.push(abbreviate_name(l)) unless l.blank?
       end
       authors_list.each do |l|
         if l == authors_list.first #first
           authors_list_final.push(l.strip)
         elsif l == authors_list.last #last
           authors_list_final.push(", &amp; " + l.strip)
         else #all others
           authors_list_final.push(", " + l.strip)
         end
       end
       text += authors_list_final.join
       unless text.blank?
         if text[-1,1] != "."
           text += ". "
         else
           text += " "
         end
       end
       # Get Pub Date
       text += "(" + setup_pub_date(record) + "). " unless setup_pub_date(record).nil?
       
       # setup title info
       title = setup_title_info(record)
       text += "<i>" + title + "</i> " unless title.nil?
       
       # Edition
       edition_data = setup_edition(record)
       text += edition_data + " " unless edition_data.nil?
       
       # Publisher info
       text += setup_pub_info(record) unless setup_pub_info(record).nil?
       unless text.blank?
         if text[-1,1] != "."
           text += "."
         end
       end
       text
     end
     def setup_pub_date(record)
       if !record.find{|f| f.tag == '210'}.nil?
         pub_date = record.find{|f| f.tag == '210'}
         if pub_date.find{|s| s.code == 'd'}
           date_value = pub_date.find{|s| s.code == 'd'}.value.gsub(/[^0-9|n\.d\.]/, "")[0,4] unless pub_date.find{|s| s.code == 'd'}.value.gsub(/[^0-9|n\.d\.]/, "")[0,4].blank?
         end
         return nil if date_value.nil?
       end
      clean_end_punctuation(date_value) if date_value
     end
     def setup_pub_info(record)
       text = ''
       pub_info_field = record.find{|f| f.tag == '210'}
       if !pub_info_field.nil?
         a_pub_info = pub_info_field.find{|s| s.code == 'a'}
         b_pub_info = pub_info_field.find{|s| s.code == 'c'}
         a_pub_info = clean_end_punctuation(a_pub_info.value.strip) unless a_pub_info.nil?
         b_pub_info = b_pub_info.value.strip unless b_pub_info.nil?
         text += a_pub_info.strip unless a_pub_info.nil?
         if !a_pub_info.nil? and !b_pub_info.nil?
           text += " : "
         end
         text += b_pub_info.strip unless b_pub_info.nil?
       end
       return nil if text.strip.blank?
       clean_end_punctuation(text.strip)
     end

     def mla_citation_title(text)
       no_upcase = ["a","an","and","but","by","for","it","of","the","to","with","un","une","des","et","mais","par","pour","de","le","la","les","à","avec"]
       new_text = []
       word_parts = text.split(" ")
       word_parts.each do |w|
         if !no_upcase.include? w
           new_text.push(w.capitalize)
         else
           new_text.push(w)
         end
       end
       new_text.join(" ")
     end
     
     # This will replace the mla_citation_title method with a better understanding of how MLA and Chicago citation titles are formatted.
     # This method will take in a string and capitalize all of the non-prepositions.
     def citation_title(title_text)
       prepositions = ["a","about","across","an","and","before","but","by","for","it","of","the","to","with","without"]
       new_text = []
       title_text.split(" ").each_with_index do |word,index|
         if (index == 0 and word != word.upcase) or (word.length > 1 and word != word.upcase and !prepositions.include?(word))
           # the split("-") will handle the capitalization of hyphenated words
           new_text << word.split("-").map!{|w| w.capitalize }.join("-")
         else
           new_text << word
         end
       end
       new_text.join(" ")
     end

     def setup_title_info(record)
       text = ''
       title_info_field = record.find{|f| f.tag == '200'}
       if !title_info_field.nil?
         a_title_info = title_info_field.find{|s| s.code == 'a'}
         b_title_info = title_info_field.find{|s| s.code == 'e'}
         a_title_info = clean_end_punctuation(a_title_info.value.strip) unless a_title_info.nil?
         b_title_info = clean_end_punctuation(b_title_info.value.strip) unless b_title_info.nil?
         text += a_title_info unless a_title_info.nil?
         if !a_title_info.nil? and !b_title_info.nil?
           text += ": "
         end
         text += b_title_info unless b_title_info.nil?
       end
       
       return nil if text.strip.blank?
       clean_end_punctuation(text.strip) + "."
       
     end
     
     def clean_end_punctuation(text)
       if [".",",",":",";","/"].include? text[-1,1]
         return text[0,text.length-1]
       end
       text
     end  

     def setup_edition(record)
       edition_field = record.find{|f| f.tag == '205'}
       edition_code = edition_field.find{|s| s.code == 'a'} unless edition_field.nil?
       edition_data = edition_code.value unless edition_code.nil?
       if edition_data.nil? or edition_data == '1st ed.'
         return nil
       else
         return edition_data
       end    
     end
     
     def get_author_list(record)
       author_list = []
       authors_primary = record.find{|f| f.tag == '700'}
       if !authors_primary.nil?
       author_primary_firstname = authors_primary.find{|s| s.code == 'a'}.value
       author_primary_name = authors_primary.find{|s| s.code == 'b'}.value
       author_primary = author_primary_name + ' ' + author_primary_firstname
       author_list.push(clean_end_punctuation(author_primary)) 
       end
       authors_secondary_701 = record.find_all{|f| ('701') === f.tag}
       if !authors_secondary_701.nil?
         authors_secondary_701.each do |l|
           author_list.push(clean_end_punctuation(l.find{|s| s.code == 'a'}.value)) unless l.find{|s| s.code == 'a'}.value.nil?
         end
       end
       
       authors_secondary_702 = record.find_all{|f| ('702') === f.tag}
       if !authors_secondary_702.nil?
         authors_secondary_702.each do |l|
           author_list.push(clean_end_punctuation(l.find{|s| s.code == 'a'}.value)) unless l.find{|s| s.code == 'a'}.value.nil?
         end
       end
       
       author_list.uniq!
       author_list
     end
     
     # This is a replacement method for the get_author_list method.  This new method will break authors out into primary authors, translators, editors, and compilers
     def get_all_authors(record)
       translator_code = "trl"; editor_code = "edt"; compiler_code = "com"
       primary_authors = []; translators = []; editors = []; compilers = []
       record.find_all{|f| f.tag === "700" }.each do |field|
         primary_authors << field["a"] if field["a"]
       end
       record.find_all{|f| f.tag === "700" }.each do |field|
         if field["a"]
           relators = []
           relators << clean_end_punctuation(field["e"]) if field["e"]
           relators << clean_end_punctuation(field["4"]) if field["4"]
           if relators.include?(translator_code)
             translators << field["a"]
           elsif relators.include?(editor_code)
             editors << field["a"]
           elsif relators.include?(compiler_code)
             compilers << field["a"]
           else
             primary_authors << field["a"]
           end
         end
       end
       {:primary_authors => primary_authors, :translators => translators, :editors => editors, :compilers => compilers}
     end
   end
   SolrDocument.use_extension( SolrDocument::Unimarc ) 
end
