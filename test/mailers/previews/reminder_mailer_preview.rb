# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/star_mailer
class ReminderMailerPreview < ActionMailer::Preview
  def reminder_email
    ReminderMailer.with(user: User.first).reminder_email
  end
end
