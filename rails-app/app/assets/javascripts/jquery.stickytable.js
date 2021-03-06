jQuery(document).on("stickyTable", function () {
    navigator.userAgent.match(/Trident\/7\./) && $(".sticky-table").on("mousewheel", function (t) {
        console.log(t), t.preventDefault();
        var l = t.originalEvent.wheelDelta, s = $(this).scrollTop();
        $(this).scrollTop(s - l)
    }), $(".sticky-headers").scroll(function () {
        $(this).find("table tr.sticky-row th").css("top", $(this).scrollTop()), $(this).find("table tr.sticky-row td").css("top", $(this).scrollTop())
    }).scroll(), $(".sticky-ltr-cells").scroll(function () {
        $(this).find("table th.sticky-cell").css("left", $(this).scrollLeft()), $(this).find("table td.sticky-cell").css("left", $(this).scrollLeft())
    }).scroll(), $(".sticky-rtl-cells").scroll(function () {
        var t = $(this).find("table").prop("clientWidth") - $(this).prop("clientWidth");
        $(this).find("table th.sticky-cell").css("right", t - $(this).scrollLeft()), $(this).find("table td.sticky-cell").css("right", t - $(this).scrollLeft())
    }).scroll()
}), $(document).ready(function () {
    $(document).trigger("stickyTable")
});