# frozen_string_literal: true

require 'test_helper'

class ReminderMailerTest < ActionMailer::TestCase
  test 'it works' do
    starred_repositories = [
      {
        starredAt: Time.zone.today - 6.months,
        era: '6 months',
        repository: {
          owner: 'pelya',
          name: 'commandergenius'
        }
      },
      {
        starredAt: Time.zone.today - 6.months,
        era: '6 months',
        repository: {
          owner: 'kivikakk',
          name: 'koino'

        }
      },
      {
        starredAt: Time.zone.today - 1.year,
        era: '1 year',
        repository: {
          owner: 'curl',
          name: 'curl'
        }
      },
      {
        starredAt: Time.zone.today - 2.years,
        era: '2 years',
        repository: {
          owner: 'jekyll',
          name: 'jekyll'
        }
      }
    ]

    # Create the email and store it for further assertions
    email = ReminderMailer.reminder_email('you@example.com', 'gjtorikian', starred_repositories)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['no-reply@past.codes'], email.from
    assert_equal ['you@example.com'], email.to
    assert_equal '[Pastcodes] Latest report', email.subject
  end
end
