  var _paq = _paq || [];
 
  var path = window.location.pathname;
  var exp_cata = '^/catalog.*';
  var exp_accueil = '^/$';
  var exp_user = '^/(user|bookmarks|search_history|saved_searches).*';
  
  if ( path.match(exp_cata) != null )  
      _paq.push(['setDocumentTitle', 'Notices']);
  else if ( path.match(exp_user) != null )
      _paq.push(['setDocumentTitle', 'Compte utilisateur et favoris']);
  else if ( path.match(exp_accueil) != null ){
    if ( window.location.search.length == 0 ) 
      _paq.push(['setDocumentTitle', 'Page d\'accueil']);
    else
      _paq.push(['setDocumentTitle', 'Pages de résultats']);   
   }
  
  _paq.push(["trackPageView"]);
  _paq.push(["enableLinkTracking"]);

  (function() {
    var u=(("https:" == document.location.protocol) ? "https" : "http") + "://bibliotheque.clermont-universite.fr/piwik/";
    _paq.push(["setTrackerUrl", u+"piwik.php"]);
    _paq.push(["setSiteId", "12"]);
    var d=document, g=d.createElement("script"), s=d.getElementsByTagName("script")[0]; 
    g.type="text/javascript";
    g.defer=true; 
    g.async=true; 
    g.src=u+"piwik.js"; 
    s.parentNode.insertBefore(g,s);
  })();


