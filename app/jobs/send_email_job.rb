# frozen_string_literal: true

require 'github_client'

class SendEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id, frequency:)
    user = User.find_by(id: user_id)
    github_username = user.github_username
    encrypted_github_token = user.encrypted_github_token
    client = GitHubClient.new(encrypted_github_token)

    primary_email_and_scopes = client.fetch_primary_email_and_scopes
    email_address = primary_email_and_scopes[:primary_email]
    defined_scopes = primary_email_and_scopes[:scopes]
    has_public_repo_scope = defined_scopes.include?('public_repo')
    starred_repositories = client.fetch_stars(github_username, has_public_repo_scope: has_public_repo_scope)

    return if starred_repositories.blank?

    ReminderMailer.reminder_email(email_address, github_username, starred_repositories, has_public_repo_scope: has_public_repo_scope, frequency: frequency).deliver_now
  end
end
