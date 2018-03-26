Rails.application.routes.draw do
  get 'test_run', to: 'filters#test_results_for_test_runs'
  post 'test_run', to: 'filters#apply_test_run_filters'
  post 'generate_user_sql_query_by_filters', to: 'filters#generate_sql_for_displaying_on_page'
  root 'filters#test_results_for_test_runs'

  get 'performance_test_run', to: 'filters#test_results_for_performance_test_runs'
  post 'performance_test_run', to: 'filters#apply_performance_test_run_filters'

  get 'mdbci_template', to: 'filters#mdbci_template'
  get 'maxscale_cnf', to: 'filters#maxscale_cnf'
end
