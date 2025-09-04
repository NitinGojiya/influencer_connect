module ApplicationHelper
  def human_count(number)
    return "0" if number.blank?

    number = number.to_i
    if number >= 1_000_000
      "#{(number / 1_000_000.0).round(1)}M"
    elsif number >= 1_000
      "#{(number / 1_000.0).round(1)}K"
    else
      number.to_s
    end
  end
  def flash_class(type)
    case type.to_sym
    when :notice
      "alert-success"
    when :alert
      "alert-warning"
    when :error
      "alert-error"
    else
      "alert-info"
    end
  end
  def percentage_change(current, previous)
    return nil if current.nil? || previous.nil? || previous == 0
    (((current.to_f - previous.to_f) / previous.to_f) * 100).round(2)
  end

  def change_indicator(current, previous)
    change = percentage_change(current, previous)
    return "N/A" if change.nil?

    if change > 0
      { text: "+#{change}%", color: "green" }
    elsif change < 0
      { text: "#{change}%", color: "red" }
    else
      { text: "0%", color: "gray" }
    end
  end
end
