$(document).ready(function($) {
   //mise en valeur du champ "Numéros disponibles"
   $('.blacklight-periodiques_display').css("color","#00529E");
   $('.blacklight-periodiques_display').css("font-weight","bold");
   
   //gestion de l'affichage des notes
   var notes = $('.resume');
   if (notes)
    display_notes(notes);
    
   //ajout d'un lien d'impression dans le compte lecteur
   var lector = document.getElementById('compte-lecteur'); 
   if (lector)
    print_link(lector);
  
  
   function display_notes(notes){
    if(!notes) return;
     notes.each(function(){
        var note = $(this);
        //on cache le reste du texte
        note.next().hide();
        
        //on ajoute le lien pour déplier
        note.append('<a href="#" id="deplie_note">... suite</a><br />');
        
        //on ajoute la fonction deplier/replier
        $('#deplie_note').click(function(){
           note.next().slideToggle();
        });
        
     });
   }
   
   
   //impression dans le compte lecteur
   function print_link(lector){
     var print_link = document.createElement('a');
     print_link.setAttribute('href', '#');
     var print_text = document.createTextNode('Imprimer votre attestation');
     print_link.appendChild(print_text);
     print_link.appendChild(document.createElement('br'));

     // Affectation de la méthode print() au clic sur le lien
     print_link.onclick = function() {
       var title = $('#compte-lecteur > h2:first');
       title.text('Attestation d\'inscription');
       window.print(); return false; 
     }
      
     // Positionnement du lien dans la page
     if(!lector) return;
      lector.insertBefore(print_link, lector.firstChild);
   }
});
