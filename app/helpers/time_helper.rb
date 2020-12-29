# frozen_string_literal: true

module TimeHelper
  def next_date(frequency)
    date = case frequency
           when 'weekly'
             Time.zone.today.next_week.beginning_of_week
           when 'monthly'
             Time.zone.today.next_month.beginning_of_month
           end
    format_time(date)
  end

  def format_time(date)
    date.strftime('%B %-d, %Y')
  end

  def beginning_of_week?(date)
    date.strftime('%A').downcase.to_sym == Date.beginning_of_week
  end

  def beginning_of_month?(date)
    date.day == 1
  end
end
