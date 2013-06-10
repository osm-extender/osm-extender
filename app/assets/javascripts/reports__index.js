$(document).ready(function() {  
    $('.select_all_section').click(function(){
        $('.section-' + $(this).data('section-id')).prop('checked', this.checked);
    });
});

$(document).ready(function() {  
    $('#select_all_programme').click(function(){
        $('.field-programme').prop('checked', this.checked);
    });
});

$(document).ready(function() {  
    $('#select_all_events').click(function(){
        $('.field-events').prop('checked', this.checked);
    });
});
