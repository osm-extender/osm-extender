function loadTab(format) {
    $("#preview").empty().append('<P>Loading, please wait.</p>');
    $.ajax({
        url: $("#preview-"+format).attr('href'),
        cache: false,
        success: function(message) {
            if (format == 'text') {
              message = "<pre style=\"white-space: pre-wrap; background: white;\">\n" + message + "\n</pre>"
            }
            $("#preview").empty().append(message);
        }
    });
}

$(document).ready(function() {
    $("#preview-html").click(function() {
        loadTab('html');
        return false;
    });
    $("#preview-text").click(function() {
        loadTab('text');
        return false;
    });
});