# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'the enum works' do
    user = users(:bad_user)
    assert_equal 'weekly', user.frequency
    assert_raises ArgumentError do
      user.frequency = 'never!'
    end
    user.frequency = 'monthly'
    user.save
    assert_equal 'monthly', user.frequency
  end
end
