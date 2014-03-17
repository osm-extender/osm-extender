//= require ./form_criteria

$(document).ready(function() {  
    $('#select_all').click(function(){
        $('.select_email_list').prop('checked', this.checked);
    });
});
