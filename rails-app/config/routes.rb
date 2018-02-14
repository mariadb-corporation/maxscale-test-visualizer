Rails.application.routes.draw do
  get 'filter', to: 'filters#test_results_for_test_runs'
  post 'filter', to: 'filters#apply_filters'
  root 'filters#test_results_for_test_runs'
end
