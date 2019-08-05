Rails.application.routes.draw do

  post 'oauth/callback' => 'oauths#callback'
  get 'oauth/callback' => 'oauths#callback' # for use with Github
  get 'oauth/:provider' => 'oauths#oauth', :as => :auth_at_provider
  delete 'oauth/logout' => 'oauths#destroy', :as => :logout

  get 'test_run', to: 'filters#test_results_for_test_runs'
  post 'test_run', to: 'filters#apply_test_run_filters'
  post 'generate_user_sql_query_by_filters', to: 'filters#generate_sql_for_displaying_on_page'
  root 'filters#test_results_for_test_runs'

  get 'performance_test_run', to: 'filters#test_results_for_performance_test_runs'
  post 'performance_test_run', to: 'filters#apply_performance_test_run_filters'

  get 'performance_test_run_qps', to: 'filters#qps_results_for_performance_test_runs'
  post 'performance_test_run_qps', to: 'filters#apply_performance_test_run_qps_filters'

  get 'performance_test_run_axes', to: 'filters#results_for_performance_test_runs_axes'
  post 'performance_test_run_axes', to: 'filters#apply_performance_test_run_axes_filters'

  get 'mdbci_template', to: 'filters#mdbci_template'
  get 'maxscale_cnf', to: 'filters#maxscale_cnf'
end
