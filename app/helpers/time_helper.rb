# frozen_string_literal: true

module TimeHelper
  def next_date(frequency)
    date = case frequency.to_sym
           when :weekly
             Time.zone.today.next_week.beginning_of_week
           when :monthly
             (Time.zone.today + 1.month).beginning_of_month
           end
    format_time(date)
  end

  def within_range?(date, frequency)
    case frequency.to_sym
    when :weekly
      week_range = (Time.zone.today.last_week.beginning_of_week..Time.zone.today)
      week_range.any? do |w|
        w.day == date.day
      end
    when :monthly
      month_range = (Time.zone.today.last_month.beginning_of_month..Time.zone.today)
      month_range.any? do |m|
        m.month == date.month && m.day == date.day
      end
    end
  end

  def format_time(date)
    date.strftime('%B %-d, %Y')
  end

  def beginning_of_week?(date)
    date.strftime('%A').downcase.to_sym == Date.beginning_of_week.to_sym
  end

  def beginning_of_month?(date)
    date.day == 1
  end

  # lazy way to make sure job is queued before Rake bails
  def rest
    sleep(2)
  end
end
