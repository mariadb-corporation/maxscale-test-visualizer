$(document).ready(function () {
    $('#selectAllTestsBtn').click(function() {
        $('.form-check-input').each(function() {
            $(this).attr('checked', true);
        });
    });

    $('#unselectAllTestsBtn').click(function() {
        $('.form-check-input').each(function() {
            $(this).attr('checked', false);
        });
    });
});