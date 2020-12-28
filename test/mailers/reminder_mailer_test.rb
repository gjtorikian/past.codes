# frozen_string_literal: true

require 'test_helper'

class ReminderMailerTest < ActionMailer::TestCase
  test 'it works' do
    # Create the email and store it for further assertions
    # email = ReminderMailerTest.create_invite("me@example.com",
    #                                  "friend@example.com", Time.now)

    # # Send the email, then test that it got queued
    # assert_emails 1 do
    #   email.deliver_now
    # end

    # # text_part, html_part
    # # Test the body of the sent email contains what we expect it to
    # assert_equal ["me@example.com"], email.from
    # assert_equal ["friend@example.com"], email.to
    # assert_equal "You have been invited by me@example.com", email.subject
    # assert_equal read_fixture("invite").join, email.body.to_s
  end
end
