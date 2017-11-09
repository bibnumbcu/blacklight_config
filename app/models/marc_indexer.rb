$:.unshift './config'
class MarcIndexer < Blacklight::Marc::Indexer
  # this mixin defines lambda facotry method get_format for legacy marc formats
  include Blacklight::Marc::Indexer::Formats

  def initialize
    super

    settings do
      # type may be 'binary', 'xml', or 'json'
      provide "marc_source.type", "binary"
      # set this to be non-negative if threshold should be enforced
      provide 'solr_writer.max_skipped', -1
    end

    to_field "id", trim(extract_marc("001"), :first => true)
    to_field 'marc_display', get_xml
    to_field "text", extract_all_marc_values do |r, acc|
      acc.replace [acc.join(' ')] # turn it into a single string
    end
     
    to_field "language_facet", marc_languages("101a")
    to_field "format", get_format
    to_field "isbn_t",  extract_marc('010a', :separator=>nil) do |rec, acc|
         orig = acc.dup
         acc.map!{|x| StdNum::ISBN.allNormalizedValues(x)}
         acc << orig
         acc.flatten!
         acc.uniq!
    end
     
    to_field 'material_type_display', extract_marc('010b:215a:215c:215d:215e', :trim_punctuation => true)
     
    # Title fields
    #    primary title 
     
    to_field 'title_t', extract_marc('200ai')
    to_field 'title_display', extract_marc('200aehi', :trim_punctuation => true, :alternate_script=>false)
    #to_field 'title_vern_display', extract_marc('245a', :trim_punctuation => true, :alternate_script=>:only)
     
    #    subtitle
     
    to_field 'subtitle_t', extract_marc('200e')
    #to_field 'subtitle_display', extract_marc('245b', :trim_punctuation => true, :alternate_script=>false)
    #to_field 'subtitle_vern_display', extract_marc('245b', :trim_punctuation => true, :alternate_script=>:only)
     
    #    additional title fields
    to_field 'title_addl_t', 
      extract_marc(%W{
        500a
        503a
        510aei
        512ae
        513aehi
        517ae
      }.join(':'))
     
    #to_field 'title_added_entry_t', extract_marc(%W{
    #  700gklmnoprst
    #  710fgklmnopqrst
    #  711fgklnpst
    #  730abcdefgklmnopqrst
    #  740anp
    #}.join(':'))
     
    to_field 'title_series_t', extract_marc("225a:225e:225i")
     
    to_field 'title_sort', extract_marc("200ae")  
     
    # Author fields
     
    to_field 'author_t', extract_marc("700abcdfgp4:701abcdfgp4:702abcdfgp4:710abcdefghp4:711abcdefghp4:712abcdefghp4")
    to_field 'author_addl_t', extract_marc("200f:200g")
    to_field 'author_display', extract_marc("700:701:702", :alternate_script=>false)
    #to_field 'author_vern_display', extract_marc("100abcdq:110#{ATOZ}:111#{ATOZ}", :alternate_script=>:only)
    to_field 'author_facet', extract_marc("700ab:701ab:702ab", :alternate_script=>false)    

    # JSTOR isn't an author. Try to not use it as one
    to_field 'author_sort', marc_sortable_author
     
    # Subject fields
    to_field 'subject_t', extract_marc(%W(
      600abcdftxyz
      604#{ATOZ}
      605ahiklmnqxyz
      606axyz
      607axyz
      610a
    ).join(':'))
    to_field 'subject_addl_t', extract_marc("600vwxyz:610vwxyz:611vwxyz:630vwxyz:650vwxyz:651vwxyz:654vwxyz:655vwxyz")
    to_field 'subject_topic_facet', extract_marc("600abx:605abx:606ax:607ax", :trim_punctuation => true)
    to_field 'subject_topic_display', extract_marc("600abx:605abx:606ax:607ax", :trim_punctuation => true)
    to_field 'subject_era_facet',  extract_marc("600z:605z:606z:607z", :trim_punctuation => true)
    to_field 'subject_geo_facet',  extract_marc("600y:605y:606y:607y",:trim_punctuation => true )
     
    # Publication fields
    to_field 'published_display', extract_marc('210a:210c:210d', :trim_punctuation => true, :alternate_script=>false)
    to_field 'published_t', extract_marc('210c', :trim_punctuation => true, :alternate_script=>:only)
    to_field 'pub_date', marc_publication_date
     
    # Call Number fields
   # to_field 'lc_callnum_display', extract_marc('050ab', :first => true)
   # to_field 'lc_1letter_facet', extract_marc('050ab', :first=>true, :translation_map=>'callnumber_map') do |rec, acc|
   #   # Just get the first letter to send to the translation map
   #   acc.map!{|x| x[0]}
   # end

    #alpha_pat = /\A([A-Z]{1,3})\d.*\Z/
    #to_field 'lc_alpha_facet', extract_marc('050a', :first=>true) do |rec, acc|
    #  acc.map! do |x|
   #     (m = alpha_pat.match(x)) ? m[1] : nil
   #   end
    #  acc.compact! # eliminate nils
    #end

    #to_field 'lc_b4cutter_facet', extract_marc('050a', :first=>true)
     
    # URL Fields
     
    #notfulltext = /abstract|description|sample text|table of contents|/i
     to_field 'url_fulltext_display', extract_marc('856u', :trim_punctuation => true)
to_field 'url_image_display', extract_marc('856z', :trim_punctuation => true)
    #to_field('url_fulltext_display') do |rec, acc|
     # rec.fields('856').each do |f|
     #   case f.indicator2
     #   when '0'
     #     f.find_all{|sf| sf.code == 'u'}.each do |url|
     #       acc << url.value
     #     end
     #   when '2'
     #     # do nothing
     #   else
     #     z3 = [f['z'], f['3']].join(' ')
     #     unless notfulltext.match(z3)
     #       acc << f['u'] unless f['u'].nil?
     #     end
     #   end
     # end
    #end

    # Very similar to url_fulltext_display. Should DRY up.
    #to_field 'url_suppl_display' do |rec, acc|
    #  rec.fields('856').each do |f|
    #    case f.indicator2
    #    when '2'
    #      f.find_all{|sf| sf.code == 'u'}.each do |url|
    #        acc << url.value
    #      end
    #    when '0'
    #      # do nothing
    #    else
    #      z3 = [f['z'], f['3']].join(' ')
    #      if notfulltext.match(z3)
    #        acc << f['u'] unless f['u'].nil?
    #      end
    #    end
    #  end
    #end

    to_field 'braille_display', extract_marc('106a', :trim_punctuation => true)
    to_field 'fond_particulier_display', extract_marc('910p', :trim_punctuation => true)
    to_field 'fond_particulier_facet', extract_marc('910p', :trim_punctuation => true)
    to_field 'particularite_exemplaire_display', extract_marc('910v', :trim_punctuation => true)
    to_field 'particularite_exemplaire_display', extract_marc('995a', :trim_punctuation => true)
    to_field 'titres_associes_display', extract_marc('500a:510aehi', :trim_punctuation => true)
    to_field 'volume_display', extract_marc('200h:200i', :trim_punctuation => true)
    to_field 'periodiques_display', extract_marc('966a:966n', :trim_punctuation => true)
    to_field 'edition_t', extract_marc('205ab', :trim_punctuation => true)
    to_field 'edition_display', extract_marc('205a:205b', :trim_punctuation => true)

    #	Donn�es particuli�res pour certains types de documents
    to_field 'maths_display', extract_marc('206a', :trim_punctuation => true)
    to_field 'series_display', extract_marc('207a', :trim_punctuation => true)
    to_field 'music_display', extract_marc('208a', :trim_punctuation => true)        
    to_field 'informatique_display', extract_marc('230a', :trim_punctuation => true)


# Numeros speciaux
    to_field 'numeros_speciaux_display_display', extract_marc('462ax', :trim_punctuation => true)

#	Notes
    to_field 'notes_display', extract_marc(%W{300#{ATOZ}
                                              302#{ATOZ}
                                              305#{ATOZ}    
                                              320a
                                                326ab}.join(':'))
    to_field 'notes_display', extract_marc(%W{
        300#{ATOZ}
        302#{ATOZ}
        305#{ATOZ}
        320a
        326ab
      }.join(':'))
    to_field 'resume_display', extract_marc('330a', :trim_punctuation => true)
    to_field 'notes_these_display', extract_marc(%W{328#{ATOZ}}.join(':'))
    to_field 'contenu_display', extract_marc(%W{
                                                327#{ATOZ}
                                                307a
}.join(':'))
    to_field 'revue_parente_display', extract_marc('461at:461x', :trim_punctuation => true)  
    to_field 'ean_t', extract_marc('073a', :trim_punctuation => true) 
    to_field 'issn_t', extract_marc('011a', :trim_punctuation => true)    


#date de modification de la notice
    to_field 'modif_date', extract_marc('005[0-7]', :trim_punctuation => true)  

#titres pour revues
    to_field 'titre_compl_t', extract_marc('411atx:421atx:422atx:423atx', :trim_punctuation => true) 
    to_field 'titre_prec_t', extract_marc('430atx:431atx:432atx:433atx:434atx:435atx:436atx:437atx', :trim_punctuation => true) 
    to_field 'titre_suiv_t', extract_marc('440atx:441atx:442atx:443atx:444atx:445atx:446atx:447atx:448atx', :trim_punctuation => true)  


#facette pivot
#pivot_facet = script(catalogueBCU.bsh), getSupportBcu

#champs pour livres anciens
    to_field 'la_adresse_display', extract_marc('210r:210s', :trim_punctuation => true) 
    to_field 'la_complement_titre_display', extract_marc('200r', :trim_punctuation => true) 
    to_field 'la_lieu_display', extract_marc('620ad', :trim_punctuation => true) 

  end
end
