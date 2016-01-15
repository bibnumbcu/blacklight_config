# -*- encoding : utf-8 -*-
class CatalogController < ApplicationController  
  include Blacklight::Marc::Catalog

  include Blacklight::Catalog

  configure_blacklight do |config|
    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = { 
      :qt => 'search',
      :rows => 10 
    }
    
    
     #parametres pour le plugin de recherche avancée
    config.advanced_search = { 
     :qt => 'advanced',
     :form_solr_parameters => {
       "facet.field" => ["format", "localisation_facet","language_facet"],
       "facet.limit" => -1, # return all facet values
       "facet.sort" => "index" # sort by byte order of values
      }
   }
   
    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select' 
    
    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SearchHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    #config.default_document_solr_params = {
    #  :qt => 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # :fl => '*',
    #  # :rows => 1
    #  # :q => '{!raw f=id v=$id}' 
    #}

    # solr field configuration for search results/index views
    config.index.title_field = 'title_display'
    config.index.display_type_field = 'format'

    # solr field configuration for document/show views
    #config.show.title_field = 'title_display'
    #config.show.display_type_field = 'format'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.    
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or 
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.  
    #
    # :show may be set to false if you don't want the facet to be drawn in the 
    # facet bar
    config.add_facet_field 'format', :label => 'Type de document', :limit => 6, :collapse => false
   config.add_facet_field 'pub_date', :label => 'Année de publication', :query => {
       :years_5 => { :label => 'Moins de 5 ans', :fq => "pub_date:[#{Time.now.year - 5 } TO *]" },
       :years_10 => { :label => 'Moins de 10 ans', :fq => "pub_date:[#{Time.now.year - 10 } TO *]" },
       :years_25 => { :label => 'Moins 25 ans', :fq => "pub_date:[#{Time.now.year - 25 } TO *]" }
    }, :collapse => false
    config.add_facet_field 'localisation_facet', :label => 'Localisation', :limit => 25, :collapse => false
#    config.add_facet_field 'pub_date', :label => 'Année de publication', :range => true 
    config.add_facet_field 'subject_topic_facet', :label => 'Thème', :limit => 20 
    config.add_facet_field 'language_facet', :label => 'Langue', :limit => 10
    config.add_facet_field 'author_facet', :label => 'Auteur', :limit => 10
    config.add_facet_field 'fond_particulier_facet', :label => 'Fonds spécialisés', :limit => 10
    config.add_facet_field 'subject_geo_facet', :label => 'Région', :limit => 10
    config.add_facet_field 'subject_era_facet', :label => 'Période', :limit => 10
#    config.add_facet_field 'pivot_facet', :label => 'Pivot Field', :pivot => ['format', 'pivot_facet']

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display 
    config.add_index_field 'author_display', :label => 'Auteur ', :helper_method => :helper_author_method
    config.add_index_field 'published_display', :label => 'Publication '
    config.add_index_field 'format', :label => 'Type de document '
    config.add_index_field 'volume_display', :label => 'Volume '

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display 
    config.add_show_field 'author_display', :label => 'Auteur ' , :helper_method => :helper_author_method
    config.add_show_field 'titres_associes_display', :label => 'Titre associé '
    config.add_show_field 'subtitle_display', :label => 'Sous-titre '
    config.add_show_field 'volume_display', :label => 'Volume '
    config.add_show_field 'edition_display', :label => 'Edition '
    config.add_show_field 'maths_display', :label => 'Note '
    config.add_show_field 'series_display', :label => 'Note '
    config.add_show_field 'music_display', :label => 'Note '
    config.add_show_field 'informatique_display', :label => 'Note '
    config.add_show_field 'published_display', :label => 'Publication '
    config.add_show_field 'fond_particulier_display', :label => 'Fonds spécialisés '
    config.add_show_field 'material_type_display', :label => 'Description ', :helper_method => :helper_description_method
    config.add_show_field 'title_series_t', :label => 'Collection ', :helper_method => :helper_title_series_method
    config.add_show_field 'notes_display', :label => 'Note ', :helper_method => :helper_notes_method
    config.add_show_field 'resume_display', :label => 'Résumé ', :helper_method => :helper_notes_method
    config.add_show_field 'notes_these_display', :label => 'Thèse ', :helper_method => :helper_notes_method
    config.add_show_field 'contenu_display', :label => 'Contenu ', :helper_method => :helper_notes_method
    config.add_show_field 'numeros_speciaux_display', :label => 'Numéros spéciaux ', :helper_method => :helper_champ400_method
    config.add_show_field 'url_fulltext_display', :label => 'URL ', :helper_method => :helper_url_fulltext_method
    config.add_show_field 'url_suppl_display', :label => 'Plus de détails '
    config.add_show_field 'isbn_t', :label => 'ISBN '
    config.add_show_field 'issn_t', :label => 'ISSN '
    config.add_show_field 'language_facet', :label => 'Langue '
    config.add_show_field 'format', :label => 'Type de document ' 
    config.add_show_field 'subject_topic_display', :label => 'Thèmes ', :helper_method => :helper_theme_method
    config.add_show_field 'subject_era_facet', :label => 'Période '
    config.add_show_field 'subject_geo_facet', :label => 'Région '
    config.add_show_field 'revue_parente_display', :label => 'Revue parente ', :helper_method => :helper_revue_parente_method
    config.add_show_field 'titre_compl_t', :label => 'Titres complémentaires ', :helper_method => :helper_champ400_method
    config.add_show_field 'titre_prec_t', :label => 'Titres précédents ', :helper_method => :helper_champ400_method
    config.add_show_field 'titre_suiv_t', :label => 'Titres suivants ', :helper_method => :helper_champ400_method
    config.add_show_field 'periodiques_display', :label => 'Numéros disponibles ', :helper_method => :helper_multiligne_method
    config.add_show_field 'particularite_exemplaire_display', :label => 'Particularités '


    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different. 

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise. 
    
    config.add_search_field 'all_fields', :label => 'Tous les critères'
    

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields. 
    config.add_search_field("isbn") do |field|
      field.include_in_simple_select = false
      field.solr_parameters = { :qf => "isbn_t" }        
    end
    
    config.add_search_field('titre') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params. 
      field.solr_parameters = { :'spellcheck.dictionary' => 'title' }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = { 
        :qf => '$title_qf',
        :pf => '$title_pf'
      }
    end
    
    config.add_search_field('auteur') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
      field.solr_local_parameters = { 
        :qf => '$author_qf',
        :pf => '$author_pf'
      }
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as 
    # config[:default_solr_parameters][:qt], so isn't actually neccesary. 
    config.add_search_field('sujet') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
      field.qt = 'search'
      field.solr_local_parameters = { 
        :qf => '$subject_qf',
        :pf => '$subject_pf'
      }
    end
    
    config.add_search_field("date de publication") do |field|
      field.include_in_simple_select = false
      field.solr_parameters = { :qf => "pub_date" }        
   end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, pub_date_sort desc, title_sort asc', :label => 'pertinence'
    config.add_sort_field 'pub_date_sort desc, title_sort asc', :label => 'année'
    config.add_sort_field 'author_sort asc, title_sort asc', :label => 'auteur'
    config.add_sort_field 'title_sort asc, pub_date_sort desc', :label => 'titre'

    # If there are more than this many search results, no spelling ("did you 
    # mean") suggestion is offered.
    config.spell_max = 5
  end

 # surcharge de la méthode index pour l'affichage des nouveautés sur la page d'accueil
    # get search results from the solr index
    def index
      (@response, @document_list) = search_results(params, search_params_logic)
      
      #pour l'affichage des nouveautes
      localisation_values = facets_from_request ['localisation_facet']
      if !localisation_values[0].items.empty?
        @succursale = nil #||= localisation_values[0].items[0].value
        @succursale = CGI.unescape(params[:id]) if !params[:id].nil?
        month = Time.now.month
        month = month - 1 if month > 1
        month = 12 if month == 1
        month = month.to_s
        month = '0' + month if month.length() == 1
        day = Time.now.day.to_s
        day = '0' + day if day.length() == 1
        
        year = Time.now.year
        year = year - 1 if month == '12'
        modif_date = year.to_s + month + day
        
      
        query = "modif_date:[#{modif_date} TO *] pub_date:[#{Time.now.year - 3} TO *]"
#        blacklight_config.qt = "advanced"
#        Rails.logger.debug 'Bug0409123613h31 : ' + query.inspect
        (@response_nouv, @document_list_nouv) = search_results({:qt => 'advanced', :q => query, :f => {:localisation_facet => @succursale}, :defType => 'lucene', :sort => 'modif_date_sort desc', :rows => 50 }, search_params_logic )


      end
      
      respond_to do |format|
        format.html { store_preferred_view }
        format.rss  { render :layout => false }
        format.atom { render :layout => false }
        format.json do
          render json: render_search_results_as_json
        end

        additional_response_formats(format)
        document_export_formats(format)
      end
    end
  
   # surcharge de la méthode show du module catalog de blacklight
   def show
      @response, @document = fetch params[:id]

      @localisations = @document.localisations
      
      respond_to do |format|
        format.html { setup_next_and_previous_documents }
        format.json { render json: { response: { document: @document } } }

        additional_export_formats(@document, format)
      end
   end
end 
