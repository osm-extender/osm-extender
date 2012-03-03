jQuery(document).ready(function(){
        $('#accordion h3').click(function() {
                $(this).next().toggle('slow');
                return false;
        }).next().hide();
});
