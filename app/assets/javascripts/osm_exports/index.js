jQuery(document).ready(function(){
        $('.accordion_exports h2').click(function() {
                $(this).next().toggle('slow');
                return false;
        }).next().hide();
});
