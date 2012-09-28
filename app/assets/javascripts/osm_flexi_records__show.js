function changeTextSize(by) {
  $('.cell_head').css('font-size', parseInt($('.cell_head').css('font-size')) + by);
  $('.cell_data').css('font-size', parseInt($('.cell_data').css('font-size')) + by);
}
function changeRowHeight(by) {
  $('.row_head').css('height', parseInt($('.row_head').css('height')) + by);
  $('.row_data').css('height', parseInt($('.row_data').css('height')) + by);
}
function changeColumnWidth(field, by) {
  $('.cell_' + field).css('width', parseInt($('.cell_' + field).css('width')) + by);
  $('#table').css('width', parseInt($('#table').css('width')) + by);
}
