      var documents = $('.document-index');      
      
      if ( ! documents.length )
         documents = $('.document-show');         
      
      var isbns = '';
      var isbn = '';      
      documents.each(function(){
        // isbn = $(this).attr('id').replace(/<br\ \/>/g, '');
         isbn = $(this).attr('id');

         if (isbns=='')
            isbns = isbn;           
          else
            isbns = isbns +',' + isbn;
      });      
      var api_url ='http://books.google.com/books?jscmd=viewapi&bibkeys=' + isbns;   
     // alert(api_url); 
      // Talk to the server synchronously and get _GBSBookInfo object
     // document.write(unescape("%3Cscript src=" + api_url + " type='text/javascript'%3E%3C/script%3E"));
     $.ajaxSetup({ cache: true });
     $.getScript(api_url, function() {
            var documents = $('.document-index');      
            var zoom=1;
            if ( ! documents.length ){
               documents = $('.document-show');
              //zoom=1;
              add_element = $('#sidebar');
            }
            else
               add_element = 'index';

            var url = '';
            var thumbnailHTML = '';
            
            documents.each(function(){
            isbn = $(this).attr('id');
               
            var bookInfo = _GBSBookInfo[isbn];
            if ( bookInfo == null )  return true;    
         
            if (bookInfo.thumbnail_url) {
              thumbnailHTML = '<img src="' + bookInfo.thumbnail_url + '&zoom=' + zoom + '" class="couverture"/>';  
              url = '<a href="' + bookInfo.preview_url  + '" title="Google Books">' + thumbnailHTML + '</a>';
              if (add_element!='index')
               add_element.append(url);
              else
               $(this).append(url); 
           }
           
           $.ajaxSetup({ cache: false });
      });
});
