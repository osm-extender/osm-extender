$(function() {
  $("#users th a, #users .pagination a").live("click", function() {
//    $.get($("#users").attr("action"), $("#users").serialize(), function(data, textStatus, jqXHR){}, "script");
    $.getScript(this.href);
    return false;
  });
});

function filter_table(input) {
  $.get($("#users").attr("action"), $("#users").serialize(), function(data, textStatus, jqXHR){
//      $("#"+input.id)[0].focus;
  }, "script");
  return false;
}
