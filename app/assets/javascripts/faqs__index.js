//= require faqs__form

$(function() {
  $(".faqs-to-reorder").sortable({
    axis: 'y',
    handle: '.drag_handle',
    update: function(event, ui) {
        $.ajax({
            type: 'post',
            url: $(this).data('update-url'),
            data: $(this).sortable('serialize'),
            headers: {
                'X-CSRF-Token': $(this).data('csrf-token')
            }
        });
    }
  });

  $("#faq_tags").sortable({
    axis: 'y',
    handle: '.drag_handle',
    update: function(event, ui) {
        $.ajax({
            type: 'post',
            url: $(this).data('update-url'),
            data: $(this).sortable('serialize'),
            headers: {
                'X-CSRF-Token': $(this).data('csrf-token')
            }
        });
    }
  });

});
