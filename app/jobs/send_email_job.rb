# frozen_string_literal: true

class SendEmailJob < ApplicationJob
  queue_as :default
  include ClientHelper

  def perform(email_address, github_username, encrypted_gh_token)
    defined_scopes = ClientHelper.fetch_scopes(encrypted_gh_token)
    has_public_repo_scope = defined_scopes.include?('public_repo')
    starred_repositories = ClientHelper.fetch_stars(github_username, encrypted_gh_token, has_public_repo_scope: has_public_repo_scope)

    return if starred_repositories.blank?

    ReminderMailer.reminder_email(email_address, github_username, starred_repositories, has_public_repo_scope: false).deliver_now
  end
end
