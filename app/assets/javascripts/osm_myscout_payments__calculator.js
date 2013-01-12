$(document).ready(function() {  
    var pc_osm = 2.95 / 100;
    var pc_gc = 1 / 100;

    $('#payment_of').keyup(function() {
        payment_of = parseFloat($(this).attr('value'));
        $(".payment_amount").html(payment_of.toFixed(2));
        $("#get_osm").html((payment_of - (payment_of * pc_osm)).toFixed(2));
        $("#get_gc").html((payment_of - (payment_of * pc_gc)).toFixed(2));
        $("#charge_osm").html((payment_of / (1 - pc_osm)).toFixed(2));
        $("#charge_gc").html((payment_of / (1 - pc_gc)).toFixed(2));
    });
});
