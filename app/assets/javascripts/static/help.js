jQuery(document).ready(function(){
        $('.accordion_faqs h3').click(function() {
                $(this).next().toggle('slow');
                return false;
        }).next().hide();
});
