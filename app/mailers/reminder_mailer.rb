# frozen_string_literal: true

class ReminderMailer < ApplicationMailer
  helper ApplicationHelper

  def reminder_email(email_address, github_username, starred_repositories)
    @github_username = github_username

    @view = Mailers::ReminderView.new(@github_username, starred_repositories)

    mail(to: email_address, subject: '[Pastcodes] Latest report')
  end
end
