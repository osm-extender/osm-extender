// This is a manifest file will include application wide java scripts
// javascripts (or manifests) for specific controllers should be
// called <controller>.js(.coffee), for example projects.js.
//
//= require_self



var minimum_haystack_size = Math.pow(10, 14);

function checkPasswordStrength(password) {
    if (password.length > 0) {
        var strength = getPasswordHaystackSize(password) / minimum_haystack_size;
        div = $('#password_strength_meter')
        div.html(getPasswordStrengthDescription(strength));
        div.css("background-color", getPasswordStrengthColor(strength));
    } else {
        div.html('No password!');
        div.css('background-color', '#7777ff');
    }
}

function getPasswordStrengthColor(strength) {
    if (strength < 0.000002) {return "#ff2222" }
    if (strength < 0.002) {return "#ff5555" }
    if (strength < 1) {return "#ff8888" }
    if (strength < 10) {return "#99ff99" }
    if (strength < 10000) {return "#55ff55" }
    return "#22ff22"
}

function getPasswordStrengthDescription(strength) {
    if (strength < 0.000002) {return "Very weak" }
    if (strength < 0.002) {return "Weak" }
    if (strength < 1) {return "Nearly strong enough" }
    if (strength < 10) {return "Strong enough" }
    if (strength < 10000) {return "Strong" }
    return "Very strong"
}

function getPasswordHaystackSize(password) {
    var alphabet_size = 0;
    alphabet_size += (password.match(/[A-Z]/) == null) ? 0 : 26;
    alphabet_size += (password.match(/[a-z]/) == null) ? 0 : 26;
    alphabet_size += (password.match(/[0-9]/) == null) ? 0 : 10;
    alphabet_size += (password.match(/[^A-Za-z0-9]/) == null) ? 0 : 33;	

    var haystack_size = alphabet_size * Math.pow((alphabet_size + 1), (password.length - 1));
    return haystack_size
}



function graphStepSize(range, targetSteps) {
  if (range == 0) {
    range = 1;
  }

  // Initial guess for step size
  var tempStep = range / targetSteps;

  // Get magnitude of step size
  var mag = Math.floor(Math.log(tempStep) / Math.LN10); // Floor the log10 of tempStep
  var magPow = Math.pow(10, mag);

  // Make the most significant digit a 'nice' one
  var magMsd = Math.floor((tempStep / magPow) + 0.5);
  if (magMsd > 5) {
    magMsd = 10;
  } else if (magMsd > 2) {
    magMsd = 5;
  } else if (magMsd > 1) {
    magMsd = 2;
  }

  return(magMsd * magPow);
}

function graphGridLines(range, targetSteps) {
  return Math.ceil(range / graphStepSize(range, targetSteps)) + 1; // Add one for the x axis
}
