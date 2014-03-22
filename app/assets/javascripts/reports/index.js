$(document).ready(function() {  
    $('.calendar_select_all_section').click(function(){
        $('.calendar_section-' + $(this).data('section-id')).prop('checked', this.checked);
    });
});

$(document).ready(function() {  
    $('#calendar_select_all_programme').click(function(){
        $('.calendar_programme').prop('checked', this.checked);
    });
});

$(document).ready(function() {  
    $('#calendar_select_all_events').click(function(){
        $('.calendar_events').prop('checked', this.checked);
    });
});


$(document).ready(function() {
    $('.leader_access_audit_select_group').click(function(){
        $('.leader_access_audit_group-' + $(this).data('group-id')).prop('checked', this.checked);
    });
});


jQuery(document).ready(function(){
        $('.accordion_reports h2').click(function() {
                $(this).next().toggle('slow');
                return false;
        }).next().hide();
});

