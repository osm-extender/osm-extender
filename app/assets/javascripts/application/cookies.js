// See https://davidmles.com/usable-cookie-bar-rails/

var cookiesAllowed = null;

function allowCookies() {
  Cookies.set('allow_cookies', 'yes', {expires: 365});
  cookiesAllowed = 'yes';
  $('#cookies-bar').fadeOut();
  cookiesPermitted();
}

function cookiesPermitted() {
  if ($('body').data('ga-tracking-id')) {
    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
      (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
    })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
    ga('create', $('body').data('ga-tracking-id'), 'auto');
    ga('send', 'pageview');
  }
}

function ready(){
  cookiesAllowed = Cookies.get('allow_cookies');
  if(cookiesAllowed == 'yes'){
    // Cookies have already been allowed
    cookiesPermitted();
  }

  // activate the accept link
  $('#cookies-accept').on('click', function(e){
    allowCookies();
    e.preventDefault();
  });
 
  // allow cookies by clicking on any link (including the cookies bar button)
  //$('a').on('click', function(e){
  //  if(cookiesAllowed != 'yes') {
  //    allowCookies();
  //  }
  //});

  // allow cookies by scrolling
  //$(document).scroll(function(){
  //  if(cookiesAllowed != 'yes') {
  //    allowCookies();
  //  }
  //});
}

$().ready(ready);
$().on('page:load', ready);
