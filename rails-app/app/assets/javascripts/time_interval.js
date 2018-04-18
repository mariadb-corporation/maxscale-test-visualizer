function setTimeIntervalFormVisibility() {
    var value = parseInt($("#time_interval_dropdown option:selected").val());

    if (value == -2) {
        $("#time_interval_form").show();
    } else {
        $("#time_interval_form").hide();
    }
}

$(document).ready(function () {
    $("#time_interval_dropdown").change(function() {
        setTimeIntervalFormVisibility();
    });

    setTimeIntervalFormVisibility();
});