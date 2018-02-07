Rails.application.routes.draw do
  get 'filters/test_results_for_test_runs'
  root 'filters#test_results_for_test_runs'
end
