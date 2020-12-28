# frozen_string_literal: true

class SendEmailJob < ApplicationJob
  queue_as :default
  include ClientHelper

  def perform(email_address, github_username, encrypted_gh_token)
    starred_repositories = ClientHelper.fetch_stars(github_username, encrypted_gh_token)

    return if starred_repositories.blank?

    ReminderMailer.reminder_email(email_address, github_username, starred_repositories).deliver_now
  end
end
