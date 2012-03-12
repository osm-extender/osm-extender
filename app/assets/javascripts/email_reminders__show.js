$(document).ready(function() {
    $("#preview-html").click(function() {
        message = "<iframe src=\"" + $("#preview-html").attr("href") + "\" style=\"width: 98%; height: 600px;\"></iframe>";
        $("#preview").empty().append(message);
        $("#preview-html").empty().append("[Reload Preview]");
        return false;
    });
});