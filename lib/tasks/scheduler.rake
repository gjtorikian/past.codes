# frozen_string_literal: true

require "#{Rails.root}/app/helpers/time_helper" # rubocop:disable  Rails/FilePath

namespace :scheduler do
  include TimeHelper

  # runs once a week, on beginning of week
  task weekly_delivery: :environment do
    next puts 'Not the beginning of the week; not running' unless beginning_of_week?(Time.zone.today)

    User.where(frequency: :weekly).each do |user|
      SendEmailJob.perform_later(user.id, frequency: :weekly)
    end
    rest
  end

  # runs the first of every month
  task monthly_delivery: :environment do
    next puts 'Not the beginning of the month; not running' unless beginning_of_month?(Time.zone.today)

    User.where(frequency: :monthly).each do |user|
      SendEmailJob.perform_later(user.id, frequency: :monthly)
    end
    rest
  end

  # test me!
  task test_delivery: :environment do
    User.where(github_username: 'gjtorikian').each do |user|
      SendEmailJob.perform_later(user.id, frequency: :weekly)
    end
    rest
  end
end
