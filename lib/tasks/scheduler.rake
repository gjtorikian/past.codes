# frozen_string_literal: true

namespace :scheduler do
  # runs once a week, on Sundays
  task weekly_delivery: :environment do
    User.where(frequency: :weekly).each do |user|
      SendEmailJob.perform_later(user.email_address, user.github_username, user.encrypted_gh_token)
    end
  end

  # runs the first of every month
  task monthly_delivery: :environment do
    User.where(frequency: :monthly).each do |user|
      SendEmailJob.perform_later(user.email_address, user.github_username, user.encrypted_gh_token)
    end
  end
end
