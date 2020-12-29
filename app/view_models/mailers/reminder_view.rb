# frozen_string_literal: true

module Mailers
  class ReminderView < ViewModel
    include TimeHelper

    attr_reader :starred_repositories

    def initialize(github_username, starred_repositories)
      super
      @github_username = github_username
      @starred_repositories = append_era(sort_by_starred_at(starred_repositories))
    end

    def github_owner_url(owner)
      "https://github.com/#{owner}"
    end

    def github_repo_url(owner, repo)
      "https://github.com/#{owner}/#{repo}"
    end

    def settings_url
      "#{ENV['BASE_URL']}/settings"
    end

    # sorts newest to oldest
    private def sort_by_starred_at(starred_repositories)
      starred_repositories.sort do |a, b|
        if a[:starredAt] < b[:starredAt]
          1
        elsif a[:starredAt] > b[:starredAt]
          -1
        else
          a[:starredAt] <=> b[:starredAt]
        end
      end
    end

    private def append_era(starred_repositories)
      starred_repositories.each_with_object([]) do |item, arr|
        next if item[:starredAt] > 6.months.ago

        item[:era] = distance_of_time_in_words(item[:starredAt], Time.zone.today)
        arr << item
      end
    end
  end
end
