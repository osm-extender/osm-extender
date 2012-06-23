// This is a manifest file will include application wide java scripts
// javascripts (or manifests) for specific controllers should be
// called <controller>.js(.coffee), for example projects.js.
//
//= require_self

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
