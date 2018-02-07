class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def ranges_string_to_sql(field, ranges_string)
    return '' if ranges_string.nil?

    result = []
    ranges = ranges_string.delete(' ').split(',')
    return '' if ranges.nil? || ranges.empty?

    ranges.each do |range|
      if range.include?('-')
        range_values = range.split('-')
        if range_values.size == 2 && is_i?(range_values[0]) && is_i?(range_values[1])
          left_value = [range_values[0].to_i, range_values[1].to_i].min
          right_value = [range_values[0].to_i, range_values[1].to_i].max
          result << " (#{field} BETWEEN '#{left_value}' AND '#{right_value}')"
        end
      elsif is_i?(range)
        result << " (#{field} = #{range.to_i})"
      end
    end
    result.join(' OR')
  end

  def is_i?(str)
    str.to_i.to_s == str
  end
end
