$(document).ready(function() {
    // Percentages taken by OSM and GoCardless (not via. OSM)
    var pc_gc = 1;
    var pc_osm = 1.95; // (the quoted 2.95% figure includes GC's 1%)
    // Note that OSM's and GC's cut are calculated seperatly and both rounded up

    $('#payment_of').keyup(function() {
        // Get value entered (as pence)
        payment_of = parseFloat($(this).prop('value')) * 100;

        // Calculate what we'll get if we charge payment_of
        get_gc = payment_of - rounded_pc_of(pc_gc, payment_of);
        get_osm = get_gc - rounded_pc_of(pc_osm, payment_of);

        // Calculate how much to charge to ensure we'll get payment_of
        charge_gc = Math.ceil(payment_of / (100 - pc_gc) * 100);
        // get initial guess and then refine until we get the right answer
        charge_osm = Math.ceil(payment_of / (100 - (pc_gc + pc_osm)) * 100);
        do {
            would_get_from_osm = charge_osm - rounded_pc_of(pc_gc, charge_osm) - rounded_pc_of(pc_osm, charge_osm);
            not_enough = (would_get_from_osm < payment_of);
            if (not_enough) {
                charge_osm += 1;
            }
        } while (not_enough);

        // Populate answer cells
        $(".payment_amount").html((payment_of / 100).toFixed(2));
        $("#get_osm").html((get_osm / 100).toFixed(2));
        $("#get_gc").html((get_gc / 100).toFixed(2));
        $("#charge_osm").html((charge_osm / 100).toFixed(2));
        $("#charge_gc").html((charge_gc / 100).toFixed(2));
    });
});

function rounded_pc_of(percentage, amount) {
    return Math.ceil(amount * (percentage / 100));
}
