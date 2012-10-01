function changeTextSize(by) {
  $('.field_head').css('font-size', parseInt($('.field_head').css('font-size')) + by);
  $('.field_data').css('font-size', parseInt($('.field_data').css('font-size')) + by);
  $('.field_total').css('font-size', parseInt($('.field_total').css('font-size')) + by);
  $('.field_count').css('font-size', parseInt($('.field_count').css('font-size')) + by);
  $('.label').css('font-size', parseInt($('.label').css('font-size')) + by);
}
function changeRowHeight(by) {
  $('.row_head').css('height', parseInt($('.row_head').css('height')) + by);
  $('.row_data').css('height', parseInt($('.row_data').css('height')) + by);
  $('.row_total').css('height', parseInt($('.row_total').css('height')) + by);
  $('.row_count').css('height', parseInt($('.row_count').css('height')) + by);
}
function changeColumnWidth(field, by) {
  $('.field_' + field).css('width', parseInt($('.field_' + field).css('width')) + by);
  $('#table').css('width', parseInt($('#table').css('width')) + by);
}
