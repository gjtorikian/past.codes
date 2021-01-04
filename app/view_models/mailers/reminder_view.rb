# frozen_string_literal: true

module Mailers
  class ReminderView < ViewModel
    include TimeHelper

    attr_reader :github_username, :has_public_repo_scope, :starred_repositories

    def initialize(github_username, starred_repositories, has_public_repo_scope:, frequency:)
      super
      @github_username = github_username
      @has_public_repo_scope = has_public_repo_scope
      @starred_repositories = starred_repositories

      @frequency = frequency
    end

    # TODO: probably a better way to arrange this but whatever
    def sort_and_filter_and_assemble!
      sort_by_starred_at!
      filter_by_starred_at!
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
        if a[:starred_at] < b[:starred_at]
          1
        elsif a[:starred_at] > b[:starred_at]
          -1
        else
          a[:starred_at] <=> b[:starred_at]
        end
      end
    end

    def filter_by_starred_at!
      @starred_repositories = @starred_repositories.each_with_object([]) do |item, arr|
        next unless within_range?(item[:starred_at], @frequency)

        arr << item
      end
    end

    def append_era!
      @starred_repositories = @starred_repositories.each_with_object([]) do |item, arr|
        next if item[:starred_at] > 6.months.ago

        item[:era] = distance_of_time_in_words(item[:starred_at], Time.zone.today)
        arr << item
      end
    end

    def assemble_descriptions!
      @starred_repositories = @starred_repositories.each_with_object([]) do |item, arr|
        repo = item[:repository]

        full_description = []
        full_description << repo[:description].sub(/(?:[!.]+\s*$)|(?<=\S$)/, '.') if repo[:description].present?
        full_description << "It appears to be written in #{repo[:primary_language].name}." if repo[:primary_language].present? && repo[:primary_language].name.present?

        full_description << "They're looking for sponsors!" if repo[:funding_links].present?

        item[:repository][:full_description] = full_description.join(' ')

        arr << item
      end
    end
  end
end
