//= require email_lists__form_criteria

$(document).ready(function() {  
    $('#select_all').click(function(){
        $('.select_email_list').attr('checked', this.checked);
    });
});
