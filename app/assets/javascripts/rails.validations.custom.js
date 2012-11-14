clientSideValidations.validators.local["email_format"] = function(element, options) {
  if (!/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i.test(element.val())) {
    return options.message;
  }
}

clientSideValidations.validators.local["time24h_format"] = function(element, options) {
  if (!/^(?:[0-1][0-9]|2[0-3]):[0-5][0-9]$/i.test(element.val())) {
    return options.message;
  }
}

clientSideValidations.validators.local["date_format"] = function(element, options) {
  if (!/^[0-9]{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12][0-9]|3[0-1])$/i.test(element.val())) {
    return options.message;
  }
}
