# frozen_string_literal: true

class ReminderMailer < ApplicationMailer
  include TimeHelper

  def reminder_email(email_address, github_username, starred_repositories, has_public_repo_scope: false)
    date = format_time(Time.zone.today)
    @view = Mailers::ReminderView.new(github_username, starred_repositories, has_public_repo_scope: has_public_repo_scope)

    mail(to: email_address, subject: "[Pastcodes] Latest report for #{date}")
  end
end
