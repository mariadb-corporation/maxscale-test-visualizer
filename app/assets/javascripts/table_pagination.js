function goToPage(pageNum, pageSize) {
    $("[pagination = true] tbody tr").each(function(index, object) {
        if (index < (pageNum - 1) * pageSize || index >= (pageNum) * pageSize) {
            $(object).hide();
        } else {
            $(object).show();
        }
    })
    $("#currentPageLabel").attr("data-current-page", pageNum);
    $("#currentPageLabel").text(pageNum);
}

function currentPage() {
    return parseInt($("#currentPageLabel").attr("data-current-page"));
}

function pageSize() {
    return parseInt($("#itemsPerPageCountSelect").attr("data-items-per-page-count"));
}

function rowsCount() {
    return parseInt($("#main-table").attr("rows-count"));
}

function pagesCount() {
    return Math.ceil(rowsCount() / pageSize());
}

$(document).ready(function () {
    // To first page
    $("#firstTablePageButton").click(function() {
        goToPage(1, pageSize());
    });

    // To previous page
    $("#previousTablePageButton").click(function() {
        if(currentPage() - 1 > 0) {
            goToPage(currentPage() - 1, pageSize());
        }
    });

    // To next page
    $("#nextTablePageButton").click(function() {
        if(currentPage() + 1 <= pagesCount()) {
            goToPage(currentPage() + 1, pageSize());
        }
    });

    // To last page
    $("#lastTablePageButton").click(function() {
        goToPage(pagesCount(), pageSize());
    });


    $("#itemsPerPageCountSelect").change(function() {
        var newPageSize = parseInt($("#itemsPerPageCountSelect option:selected").val());
        $("#itemsPerPageCountSelect").attr("data-items-per-page-count", newPageSize);
        goToPage(1, newPageSize);
    });

    goToPage(currentPage(), pageSize());
});