$(function() {
  $("#users th a, #users .pagination a").on("click", function() {
    $.getScript(this.href);
    return false;
  });
});

function filter_table(input) {
  $.get($("#users").prop("action"), $("#users").serialize(), function(data, textStatus, jqXHR){
  }, "script");
  return false;
}
