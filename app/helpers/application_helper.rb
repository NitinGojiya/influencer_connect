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
end
