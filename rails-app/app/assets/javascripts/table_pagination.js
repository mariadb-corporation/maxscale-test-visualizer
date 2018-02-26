// Scripts for the table pagination

function setPageNumLabel() {
    var text = "Page: " + currentPage() +  " of " + pagesCount();
    $("#currentPageLabel").text(text);
}

function setPageNum(pageNum) {
    $("#pageNum").val(pageNum);
}

function goToPage(pageNum) {
    setPageNum(pageNum);
    setPageNumLabel();
    $("#filtersForm").submit();
}

function currentPage() {
    return parseInt($("#pageNum").val());
}

function pageSize() {
    return parseInt($("#tableColumnsCount").val());
}

function pagesCount() {
    return parseInt($("#tablePagesCount").val());
}

function refreshPageData() {
    if (!currentPage()) {
        setPageNum(pagesCount());
    }

    if (!pageSize()) {
        $("#tableColumnsCount").val($("#itemsPerPageCountSelect").children().first().val());
        $("#itemsPerPageCountSelect").val($("#itemsPerPageCountSelect").children().first().val());
    }

    $("#itemsPerPageCountSelect").val(pageSize());

    setPageNum(currentPage());
    setPageNumLabel();
}



function formAjaxRequest() {
    $("#filtersForm").ajaxSubmit({
        url: "/filter",
        type: 'POST',
        dataType: 'json',
        success: function(data){
            $("#main-table-container").empty().append(data.partial);
            $("#flashesContainer").empty().append(data.flashes);

            $("#pageNum").val(data.page_num);
            $("#tableColumnsCount").val(data.table_columns_count);
            $("#tablePagesCount").val(data.table_pages_count);
            $("#totalCount").text('(Total count: ' + data.total_count + ')');

            refreshPageData();
            $(document).trigger("stickyTable");
            initPopover();
            setDisabled();
            $('.loader-container').hide();
        },
        error: function(data) {
        }
    })
}

$(document).ready(function () {
    // To first page
    $("#firstTablePageButton").click(function() {
        goToPage(1);
    });

    // To previous page
    $("#previousTablePageButton").click(function() {
        if (currentPage() - 1 > 0) {
            goToPage(currentPage() - 1);
        }
    });

    // To next page
    $("#nextTablePageButton").click(function() {
        if (currentPage() + 1 <= pagesCount()) {
            goToPage(currentPage() + 1);
        }
    });

    // To last page
    $("#lastTablePageButton").click(function() {
        goToPage(pagesCount());
    });

    // When select page size
    $("#itemsPerPageCountSelect").change(function() {
        var newPageSize = $("#itemsPerPageCountSelect option:selected").val();

        $("#tableColumnsCount").val(newPageSize);

        setPageNum(-1);
        $("#filtersForm").submit();
    });

    $("#submitButton").click(function() {
        setPageNum(-1);

    })

    $("#filtersForm").submit(function( event ) {
        event.preventDefault();
        $('.loader-container').show();
        formAjaxRequest();
        return false;
    });

    refreshPageData();
    $('.loader-container').hide();

});