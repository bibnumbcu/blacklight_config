Blacklight.facet_expand_contract = function() {
       $(this).next("ul, div").each(function(){
           var f_content = $(this);
           $(f_content).prev('h5').addClass('twiddle');
           // find all f_content's that don't have any span descendants with a class of "selected"
           if($('span.selected', f_content).length == 0){
             // hide it
             if ( ! (f_content.parent('div').hasClass('blacklight-format') 
                  || f_content.parent('div').hasClass('blacklight-localisation_facet')
                  || f_content.parent('div').hasClass('blacklight-pub_date')) )
                f_content.hide();
                else
                $(this).prev('h5').addClass('twiddle-open');
           } else {
             $(this).prev('h5').addClass('twiddle-open');
           }

           // attach the toggle behavior to the h3 tag
           $('h5', f_content.parent()).click(function(){
               // toggle the content
               $(this).toggleClass('twiddle-open');
               $(f_content).slideToggle();
           });
       });
   };

