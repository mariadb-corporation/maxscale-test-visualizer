// Scripts for the pop-up window for selecting tests

function selectedTestsCount() {
    return $('#selectTestsModalBody input:checkbox:checked').length;
}

function testsCount() {
    return $('#selectTestsModalBody input:checkbox').length;
}

function updateSelectTestsButtonText() {
    $('#selectTestsButton').text('Select tests (' + selectedTestsCount().toString() + ' of ' + testsCount().toString() + ')');
}

$(document).ready(function () {
    $('#selectAllTestsBtn').click(function() {
        $('#selectTestsModalBody input:checkbox').each(function() {
            $(this)[0].checked = true;
        });
    });

    $('#unselectAllTestsBtn').click(function() {
        $('#selectTestsModalBody input:checkbox').each(function() {
            $(this)[0].checked = false;
        });
    });

    $('#selectTestsModal').on('hide.bs.modal', function (e) {
        updateSelectTestsButtonText();
    })

    updateSelectTestsButtonText();
});