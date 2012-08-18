$(function() {
  $("#items").sortable({
    axis: 'y',
    handle: '.drag_handle',
    update: function(event, ui) {
        $.ajax({
            type: 'post',
            url: $(this).data('update-url'),
            data: $(this).sortable('serialize'),
            error: function(jqXHR, textStatus, errorThrown) {alert("An error occured whilst saving the new order.\n" + textStatus);},
            success: function(data, textStatus, jqXHR) {alert("Your new order was saved.");},
            headers: {
                'X-CSRF-Token': $(this).data('csrf-token')
            }
        });
    }
  });
});
