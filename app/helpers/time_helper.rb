# frozen_string_literal: true

module TimeHelper
  def next_date(frequency)
    date = case frequency
           when 'weekly'
             Time.zone.today.next_week
           when 'monthly'
             Time.zone.today.next_month.beginning_of_week
           end
    format_time(date)
  end

  def format_time(date)
    date.strftime('%B %-d, %Y')
  end
end
