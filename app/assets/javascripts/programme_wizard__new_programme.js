$(function() {
  $( ".datepicker" ).datepicker({
    showOn: 'both',
    buttonImageOnly: true,
    buttonImage: '/assets/icons/calendar-small.png',
    buttonText: 'Calendar',
    constrainInput: true,
    dateFormat: 'yy-mm-dd',
    changeMonth: true,
    changeYear: true,
    onClose: function(dateText, inst) { $(inst.input).change().focusout(); }
  });
});
