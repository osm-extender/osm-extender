$(document).ready(function() {  
    $('#email_list_section_id').change(function() {
        var data = sections_data[$(this).prop('value')];

        // Change content of groupings select box
        $('#email_list_match_grouping option:gt(0)').remove();
        var sb = $('#email_list_match_grouping');
        $.each(data['groupings'], function(key, value) {
            sb.append('<option value="'+ value +'">'+ key +'</option>');
        });

        // Change grouping name
        $("#grouping_name").html(data['grouping_name']);

    });
});
