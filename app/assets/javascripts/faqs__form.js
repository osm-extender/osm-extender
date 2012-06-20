$(document).ready(function () {
    $('#faq_tag_tokens').tokenInput('/faq_tags.json', {
        prePopulate: $('#faq_tag_tokens').data('load')
    });
});
