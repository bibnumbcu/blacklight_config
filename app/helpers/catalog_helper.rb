# encoding: utf-8
module CatalogHelper
  include Blacklight::CatalogHelperBehavior
  
  def render_nouveautes_links (localisation=nil)
    values = facets_from_request ['localisation_facet']
    result ='<ul>'
    values[0].items.map{|one_item|
	  next if one_item.value == 'Bibliothèque IUT Cézeaux' || one_item.value == 'Polytech ISIMA' || one_item.value == 'B.U. STAPS'
	  if localisation == one_item.value
        result += '<li><a class="active" href="/nouveautes/' + CGI.escape(one_item.value) + '">' + one_item.value + '</a></li>'
      else
        result += '<li ><a href="/nouveautes/' + CGI.escape(one_item.value) + '">' + one_item.value + '</a></li>'
      end
    }
    result = result + '</ul>'
    result.html_safe
  end
  
  def render_bouton_empruntable(empruntable)
     image = 'bouton-vert.png'
     image = 'bouton-rouge.png'  if !empruntable
     image_tag(image, {:class => "disponibilite",:title=>"Disponibilité"})    
  end
  
  def replace_bad_accent(document)
     document.gsub(/nÊÊ/i, 'n°').html_safe
  end
   
  #fonction pour couper une phrase a un certain nombre de mots (limit)
  def cut_words (words, limit)
   words = words.split(" ")
   result = ""
   result += words.first(limit).join(" ")
   result += "..." if words.length > limit
   raw result
  end
  
   def render_disponibilite localisations, format
      disponibilite = false
      if localisations.empty?
         disponibilite = true if format =~ /Revue/i ||
                                 format =~ /Revue électronique/i ||
                                 format =~ /Ressource électronique/i ||
                                 format =~ /Livre électronique/i
      else
         localisations.each { |one_line|
            disponibilite = true if one_line[:empruntable] 
         } 
      end
      render_bouton_empruntable(disponibilite)
  end
  
  def affichage_exemplaire type, exemplaire
   affichage = true
   affichage = false  if exemplaire[:affichable] != 'c' 
   affichage = false if  !((type=='Revue' &&  ( exemplaire[:statut]=='Exemplaire générique' || exemplaire[:cote_suppl]=='5PSF')) || (type!='Revue') )
   affichage
  end

end
