module FiltersHelper
  def format_test_result(test_result)
    test_result.nil? ? '' : test_result.result
  end
end
