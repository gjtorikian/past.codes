# frozen_string_literal: true

module TimeHelper
  def next_date(frequency)
    case frequency
    when 'weekly'
      Time.zone.today.next_week
    when 'monthly'
      Time.zone.today.next_month.beginning_of_month
    end.strftime('%B %d, %Y')
  end
end
