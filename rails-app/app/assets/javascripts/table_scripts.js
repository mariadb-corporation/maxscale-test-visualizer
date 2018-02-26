// Scripts for the result table: setting up the pop-up window, scroll table to the right

function initPopover() {

    $('.sticky-table').scrollLeft($('#main-table').width());

    $(function () {
        $('[data-toggle="popover"]').popover({
            trigger: 'focus',
            html: true,
            content: function() {
                return $(this).attr('data-content').html();
            }
        })
    })
}

$(document).ready(function () {
    initPopover();
});
