# frozen_string_literal: true

namespace :mailer do
  task preview: :environment do
    pp ReminderMailerPreview.new.send_test_mail
  end
end
