var minimum_haystack_size = Math.pow(10, 14);
var log_minimum_haystack_size = Math.log(minimum_haystack_size);

function checkPasswordStrength(password) {
    if (password.length > 0) {
        var strength = passwordHaystackSize(password) / minimum_haystack_size;
        div = $('#password_strength_meter')
        div.html(getPasswordStrengthDescription(strength) + ".\n" + getPasswordTips(password));
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

function getPasswordTips(password) {
    if ((password.length >= 1) && (passwordHaystackSize(password) < minimum_haystack_size)) {
        tips = "\n<ul>";
        if (password.match(/[A-Z]/) == null)
            tips += '<li>Try adding some uppercase letters</li>';
        if (password.match(/[a-z]/) == null)
            tips += '<li>Try adding some lowercase letters</li>';
        if (password.match(/[0-9]/) == null)
            tips += '<li>Try adding some numbers</li>';
        if (password.match(/[^A-Za-z0-9]/) == null)
            tips += '<li>Try adding some special characters, e.g. !"£$%^&*(){}[]@<>?|\/#~;:</li>';
        tips += "<li>Or just make it another ";
        tips += (minimumPasswordLength(password) - password.length);
        tips += " characters longer</li></ul>\n";
        return tips;
    } else {
        return '';
    }
}

function passwordHaystackSize(password) {
    var alphabet_size = passwordAlphabetSize(password);
    return alphabet_size * Math.pow(alphabet_size, password.length);
}

function passwordAlphabetSize(password) {
    var alphabet_size = 0;
    alphabet_size += (password.match(/[A-Z]/) == null) ? 0 : 26;
    alphabet_size += (password.match(/[a-z]/) == null) ? 0 : 26;
    alphabet_size += (password.match(/[0-9]/) == null) ? 0 : 10;
    alphabet_size += (password.match(/[^A-Za-z0-9]/) == null) ? 0 : 33;
    return alphabet_size;
}

function minimumPasswordLength(password) {
    var log_alphabet_size = Math.log(passwordAlphabetSize(password));
    return Math.ceil(log_minimum_haystack_size / log_alphabet_size) - 1;
}
