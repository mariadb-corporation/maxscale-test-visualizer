$(document).ready(function () {
    var tableOffset = $("#main-table").offset().top;
    var $header = $("#main-table > thead").clone();
    var $fixedHeader = $("#header-fixed").append($header);

    $(window).bind("scroll", function() {
        var offsetY = $(this).scrollTop();

        if (offsetY >= tableOffset && $fixedHeader.is(":hidden")) {
            $fixedHeader.show();
        }
        else if (offsetY < tableOffset) {
            $fixedHeader.hide();
        }

        var offsetX = window.pageXOffset;
        $fixedHeader.css("left", -offsetX + $("#main-table").offset().left);

        $("#header-fixed").css("width", $("#main-table").width());
    });

    $header.find('td, th').each(function(index)
    {
        var width = $("#main-table")[0].rows[0].cells[index].offsetWidth
        this.width = width;
    });

    $(function () {
        $('[data-toggle="popover"]').popover({
            trigger: 'focus',
            html: true,
            content: function() {
                return $(this).attr('data-content').html();
            }
        })
    })

});
