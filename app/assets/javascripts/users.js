$(function() {
  $("#users th a, #users .pagination a").live("click", function() {
    $.getScript(this.href);
    return false;
  });
});

function filter_table(input) {
  $.get($("#users").attr("action"), $("#users").serialize(), function(data, textStatus, jqXHR){
  }, "script");
  return false;
}
