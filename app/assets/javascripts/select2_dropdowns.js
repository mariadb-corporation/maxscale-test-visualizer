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
});