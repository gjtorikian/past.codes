# frozen_string_literal: true

class ReminderMailer < ApplicationMailer
  def reminder_email(email_address, github_username, starred_repositories)
    @github_username = github_username
    @starred_repositories = starred_repositories

    mail(to: email_address, subject: 'Welcome to My Awesome Site')
  end
end
