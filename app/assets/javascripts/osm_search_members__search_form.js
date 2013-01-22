$(document).ready(function() {  
    $('.select_all_section').click(function(){
        $('.section-' + $(this).data('section-id')).prop('checked', this.checked);
    });
});

$(document).ready(function() {  
    $('.select_all_field').click(function(){
        $('.field-' + $(this).data('field-id')).prop('checked', this.checked);
    });
});
