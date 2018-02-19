// Scripts for the enable / disable sql-query input mode

function disableInputSelects() {
    $("#mariadb_version_select").prop( "disabled", true );
    $("#maxscale_source_select").prop( "disabled", true );
    $("#box_select").prop( "disabled", true );
    $("#jenkins_build_input").prop( "disabled", true );
}

function enableInputSelects() {
    $("#mariadb_version_select").prop( "disabled", false );
    $("#maxscale_source_select").prop( "disabled", false );
    $("#box_select").prop( "disabled", false );
    $("#jenkins_build_input").prop( "disabled", false );
}

function disableSqlTextarea() {
    $("#sql_query_textarea").prop( "disabled", true );
}

function enableSqlTextarea() {
    $("#sql_query_textarea").prop( "disabled", false );
}

function setDisabled() {
    if($("#use_sql_query_check")[0].checked == true) {
        disableInputSelects();
        enableSqlTextarea();
    } else {
        enableInputSelects();
        disableSqlTextarea();
    }
}

$(document).ready(function () {
    $("#use_sql_query_check").change(function() {
        setDisabled();
    });

    setDisabled();
});