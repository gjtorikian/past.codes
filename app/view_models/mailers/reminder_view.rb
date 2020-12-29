# frozen_string_literal: true

module Mailers
  class ReminderView < ViewModel
    include TimeHelper

    attr_reader :starred_repositories

    def initialize(github_username, starred_repositories)
      super
      @github_username = github_username
      @starred_repositories = starred_repositories

      # TODO: probably a better way to arrange this but whatever
      sort_by_starred_at!
      append_era!
      assemble_descriptions!
    end

    def github_owner_url(owner)
      "https://github.com/#{owner}"
    end

    def github_repo_url(owner, repo)
      "https://github.com/#{owner}/#{repo}"
    end

    def settings_url
      "#{BASE_URL}/settings"
    end

    # sorts newest to oldest
    def sort_by_starred_at!
      @starred_repositories.sort! do |a, b|
        if a[:starredAt] < b[:starredAt]
          1
        elsif a[:starredAt] > b[:starredAt]
          -1
        else
          a[:starredAt] <=> b[:starredAt]
        end
      end
    end

    def append_era!
      @starred_repositories = @starred_repositories.each_with_object([]) do |item, arr|
        next if item[:starredAt] > 6.months.ago

        item[:era] = distance_of_time_in_words(item[:starredAt], Time.zone.today)
        arr << item
      end
    end

    def assemble_descriptions!
      @starred_repositories = @starred_repositories.each_with_object([]) do |item, arr|
        repo = item[:repository]

        full_description = []
        full_description << repo[:description].sub(/(?:[!.]+\s*$)|(?<=\S$)/, '.') if repo[:description].present?

        full_description << "It appears to be written in #{repo[:primary_language][:name]}." if repo[:primary_language].present? && repo[:primary_language][:name].present?

        full_description << "They're looking for sponsors!" if repo[:funding_links].present?

        item[:repository][:full_description] = full_description.join(' ')

        arr << item
      end
    end
  end
end
