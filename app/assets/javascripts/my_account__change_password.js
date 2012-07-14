$(function() {
    $('#new_password').keyup(function() { checkPasswordStrength(this.value) });
});
