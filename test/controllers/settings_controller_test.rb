# frozen_string_literal: true

require 'test_helper'

class SettingsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @good_user = users(:good_user)
  end

  test 'requires auth' do
    get '/settings'
    assert_redirected_to '/'
  end

  test 'it works' do
    sign_in_as(@good_user)
    assert session[:uid]
    get '/settings'
    assert_response :success
  end

  test 'can swap settings' do
    as_user(@good_user) do
      visit '/settings'
      find('#user_delivery_type_monthly').click
      click_button 'Save'
      @good_user.reload
      assert_equal 'monthly', @good_user.frequency
    end
  end
end
