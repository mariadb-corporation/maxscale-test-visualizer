module ApplicationHelper
  def selected_attr(value)
    return 'selected' if value

    ''
  end

  def checked_attr(value)
    return 'checked' if value

    ''
  end
end
