# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20181005155320) do

  create_table "db_metadata", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "version"
  end

  create_table "db_version", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "version"
  end

  create_table "maxscale_parameters", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "id"
    t.string "target", limit: 256
    t.string "maxscale_commit_id", limit: 256
    t.text "maxscale_cnf", limit: 4294967295
    t.string "maxscale_source", limit: 256, default: "NOT FOUND"
    t.string "maxscale_cnf_file_name", limit: 500
    t.integer "maxscale_threads"
    t.index ["id"], name: "id"
  end

  create_table "performance_test_run", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "jenkins_id"
    t.datetime "start_time"
    t.string "box", limit: 256
    t.string "product", limit: 256
    t.string "mariadb_version", limit: 256
    t.string "test_code_commit_id", limit: 256
    t.string "job_name", limit: 256
    t.integer "machine_count"
    t.string "sysbench_params", limit: 256
    t.text "mdbci_template", limit: 4294967295
    t.string "test_tool", limit: 256
    t.string "product_under_test", limit: 256
    t.string "test_tool_version", limit: 256, default: "NOT FOUND"
    t.integer "sysbench_threads"
  end

  create_table "results", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "id"
    t.string "test", limit: 256
    t.integer "result"
    t.string "core_dump_path", limit: 500
    t.float "test_time", limit: 24, default: 0.0
    t.index ["id"], name: "id"
  end

  create_table "sysbench_results", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "id"
    t.float "OLTP_test_statistics_queries_performed_read", limit: 24
    t.float "OLTP_test_statistics_queries_performed_write", limit: 24
    t.float "OLTP_test_statistics_queries_performed_other", limit: 24
    t.float "OLTP_test_statistics_queries_performed_total", limit: 24
    t.float "OLTP_test_statistics_transactions", limit: 24
    t.float "OLTP_test_statistics_ignored_errors", limit: 24
    t.float "OLTP_test_statistics_reconnects", limit: 24
    t.float "General_statistics_total_time", limit: 24
    t.float "General_statistics_total_number_of_events", limit: 24
    t.float "General_statistics_response_time_min", limit: 24
    t.float "General_statistics_response_time_avg", limit: 24
    t.float "General_statistics_response_time_max", limit: 24
    t.float "General_statistics_response_time_approx__95_percentile", limit: 24
    t.float "Threads_fairness_events_avg", limit: 24
    t.float "Threads_fairness_events_stddev", limit: 24
    t.float "Threads_fairness_execution_time_avg", limit: 24
    t.float "Threads_fairness_execution_time_stddev", limit: 24
    t.index ["id"], name: "id"
  end

  create_table "test_run", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "jenkins_id"
    t.datetime "start_time"
    t.string "target", limit: 256
    t.string "box", limit: 256
    t.string "product", limit: 256
    t.string "mariadb_version", limit: 256
    t.string "test_code_commit_id", limit: 256
    t.string "maxscale_commit_id", limit: 256
    t.string "job_name", limit: 256
    t.string "maxscale_source", limit: 256, default: "NOT FOUND"
    t.text "cmake_flags"
    t.string "logs_dir", limit: 256, default: "run_test-2651"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "uid"
    t.string "provider"
    t.string "name"
    t.string "image"
    t.string "nickname"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "maxscale_parameters", "performance_test_run", column: "id", name: "maxscale_parameters_ibfk_1"
  add_foreign_key "results", "test_run", column: "id", name: "results_ibfk_1"
  add_foreign_key "sysbench_results", "performance_test_run", column: "id", name: "sysbench_results_ibfk_1"
end
