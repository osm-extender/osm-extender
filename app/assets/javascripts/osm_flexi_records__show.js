function setTextSize(to) {
  $('.field_head').css('font-size', to);
  $('.field_data').css('font-size', to);
  $('.field_total').css('font-size', to);
  $('.field_count').css('font-size', to);
  $('.label').css('font-size', to);
}
function setRowHeight(to) {
  $('.row_head').css('height', to);
  $('.row_data').css('height', to);
  $('.row_total').css('height', to);
  $('.row_count').css('height', to);
}

function saveCustomSizes(csrfToken) {
  $.ajax({
    url: '/my_preferences/save_custom_sizes',
    type: 'post',
    dataType: 'json',
    headers: {'X-CSRF-Token': csrfToken},
    data: 'text_size=' + parseInt($('.field_head').css('font-size')) + '&row_height=' + parseInt($('.row_head').css('height')),
    async: false,
    success: function(data, status, jqXHR) {
      if (data['saved']) {
        alert("Your preferences were saved");
      } else {
        alert("An error occured and your preferences were not saved");
      }
    },
    error: function(jqXHR, textStatus, errorThrown) {
      alert(textStatus);
    }
  })
}


function changeTextSize(by) {
  setTextSize(parseInt($('.field_head').css('font-size')) + by);
}
function changeRowHeight(by) {
  setRowHeight(parseInt($('.row_head').css('height')) + by);
}
function changeColumnWidth(field, by) {
  $('.field_' + field).css('width', parseInt($('.field_' + field).css('width')) + by);
  $('#table').css('width', parseInt($('#table').css('width')) + by);
}
