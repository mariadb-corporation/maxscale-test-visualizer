function tableOffsetY() {
    return $("#main-table").offset().top;
}

function setHeaderCeilsWidth() {
    $('#header-fixed').find('td, th').each(function(index)
    {
        var width = $("#main-table")[0].rows[0].cells[index].offsetWidth;
        this.width = width;
    });
}

$(document).ready(function () {
    var $header = $("#main-table > thead").clone();
    var $fixedHeader = $("#header-fixed").append($header);

    $(window).bind("scroll", function() {
        var offsetY = $(this).scrollTop();

        if (offsetY >= tableOffsetY() && $fixedHeader.is(":hidden")) {
            $fixedHeader.show();
        }
        else if (offsetY < tableOffsetY()) {
            $fixedHeader.hide();
        }

        $("#header-fixed").css("width", $("#main-table").width());

        setHeaderCeilsWidth();
    });

    $('.table-container').bind("scroll", function() {
        var offsetX = window.pageXOffset;
        $fixedHeader.css("left", -offsetX + $("#main-table").offset().left);

        setHeaderCeilsWidth();
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
