// Scripts for the enable / disable sql-query input mode

function disableInputSelects() {
    $("#mariadb_version_select").prop( "disabled", true );
    $("#maxscale_source_select").prop( "disabled", true );
    $("#box_select").prop( "disabled", true );
    $("#jenkins_build_input").prop( "disabled", true );
    $("#time_interval_dropdown").prop( "disabled", true );
    $("#time_interval_start").prop( "disabled", true );
    $("#time_interval_finish").prop( "disabled", true );
    $("#dbms_select").prop( "disabled", true );
    $("#test_tool_select").prop( "disabled", true );
}

function enableInputSelects() {
    $("#mariadb_version_select").prop( "disabled", false );
    $("#maxscale_source_select").prop( "disabled", false );
    $("#box_select").prop( "disabled", false );
    $("#jenkins_build_input").prop( "disabled", false );
    $("#time_interval_dropdown").prop( "disabled", false );
    $("#time_interval_start").prop( "disabled", false );
    $("#time_interval_finish").prop( "disabled", false );
    $("#dbms_select").prop( "disabled", false );
    $("#test_tool_select").prop( "disabled", false );
}

function disableSqlTextarea() {
    $("#sql_query_textarea").prop( "disabled", true );
}

function enableSqlTextarea() {
    $("#sql_query_textarea").prop( "disabled", false );
}

function setDisabled() {
    if($("#use_sql_query_check")[0].checked == true) {
        // fillSQLQueryField();
        disableInputSelects();
        enableSqlTextarea();
    } else {
        enableInputSelects();
        disableSqlTextarea();
    }
}

function fillSQLQueryField() {
    $("#sql_query_textarea").val("");

    $("#filtersForm").ajaxSubmit({
            url: "/generate_user_sql_query_by_filters",
            type: 'POST',
            dataType: 'json',
            success: function(data){
                $("#sql_query_textarea").val(data.sql_query);
            }
        })
}

$(document).ready(function () {
    $("#use_sql_query_check").click(function() {
        if($(this)[0].checked == true) {
            fillSQLQueryField();
        }
        setDisabled();
    });

    $("#filtersForm").submit(function( event ) {
        enableInputSelects();
        enableSqlTextarea();
    });

    setDisabled();
});