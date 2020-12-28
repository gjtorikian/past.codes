# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @good_user = users(:good_user)
    @bad_user = users(:bad_user)
  end

  test "that settings can't just be changed" do
    patch "/users/#{@good_user.id}", params: { user_delivery_type: 'monthly' }
    assert_redirected_to '/'
  end

  test "that settings for someone else can't just be changed" do
    sign_in_as(@bad_user)
    assert_equal "weekly", @good_user.frequency
    patch "/users/#{@good_user.id}", params: { user_delivery_type: 'monthly' }
    assert_response :not_found
    assert_equal "weekly", @good_user.frequency
  end

  test "that settings for yourself can be changed" do
    sign_in_as(@bad_user)
    assert_equal "weekly", @bad_user.frequency
    patch "/users/#{@bad_user.id}", params: { user_delivery_type: 'monthly' }
    @bad_user.reload
    assert_equal "monthly", @bad_user.frequency
  end

  test "that users can't just be deleted" do
    assert_difference("User.count", 0) do
      delete "/users/#{@good_user.id}"
      assert_redirected_to '/'
    end
  end

  test "that users can't delete someone else" do
    assert_difference("User.count", 0) do
      sign_in_as(@bad_user)
      delete "/users/#{@good_user.id}"
      assert_response :not_found
    end
  end

  test "users can delete self after logging in as themselves" do
    assert_difference("User.count", -1) do
      sign_in_as(@bad_user)
      delete "/users/#{@bad_user.id}"
      assert_match /Sorry/, response.body
    end
  end
end
