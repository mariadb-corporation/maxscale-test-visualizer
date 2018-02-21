Rails.application.routes.draw do
  get 'filter', to: 'filters#test_results_for_test_runs'
  post 'filter', to: 'filters#apply_filters'
  post 'generate_user_sql_query_by_filters', to: 'filters#generate_sql_for_displaying_on_page'
  root 'filters#test_results_for_test_runs'
end
