// Set options for the 'select2' selectors

$(document).ready(function () {
    $("#mariadb_version_select").select2({
        theme: "bootstrap",
        placeholder: "Select a MariaDB version",
        width: null
    });
    $("#maxscale_source_select").select2({
        theme: "bootstrap",
        placeholder: "Select a Maxscale source",
        width: '100%'
    });
    $("#box_select").select2({
        theme: "bootstrap",
        placeholder: "Select a box",
        width: '100%'
    });
    $("#test_tool_select").select2({
        theme: "bootstrap",
        placeholder: "Select a test tool version",
        width: '100%'
    });
    $("#dbms_select").select2({
        theme: "bootstrap",
        placeholder: "Select a product version",
        width: '100%'
    });
    $("#maxscale_threads_select").select2({
        theme: "bootstrap",
        placeholder: "Select a maxscale threads",
        width: '100%'
    });
    $("#sysbench_threads_select").select2({
        theme: "bootstrap",
        placeholder: "Select a sysbench threads",
        width: '100%'
    });
});