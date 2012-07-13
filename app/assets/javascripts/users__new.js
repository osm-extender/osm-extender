var minimum_haystack_size = Math.pow(10, 14);

$(function() {
    $('#user_password').keyup(function() { checkStrength(this.value) });
});

function checkStrength(password) {
    if (password.length > 0) {
        var strength = getPasswordHaystackSize(password) / minimum_haystack_size;
        div = $('#password_strength_meter')
        div.html(getStrengthDescription(strength));
        div.css("background-color", getStrengthColor(strength));
    } else {
        div.html('No password!');
        div.css('background-color', '#7777ff');
    }
}

function getStrengthColor(strength) {
    if (strength < 0.000002) {return "#ff2222" }
    if (strength < 0.002) {return "#ff5555" }
    if (strength < 1) {return "#ff8888" }
    if (strength < 10) {return "#99ff99" }
    if (strength < 10000) {return "#55ff55" }
    return "#22ff22"
}

function getStrengthDescription(strength) {
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
