# frozen_string_literal: true

namespace :scheduler do
  task weekly: :environment do
    puts 'Performing database backup...'
  end

  task monthly: :environment do
    puts 'Performing database backup...'
  end
end
