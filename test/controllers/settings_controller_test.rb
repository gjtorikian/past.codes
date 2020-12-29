# frozen_string_literal: true

require 'test_helper'

class SettingsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @good_user = users(:good_user)
    @monthly_user = users(:monthly_user)
  end

  test 'requires auth' do
    get '/settings'
    assert_redirected_to '/'
  end

  test 'it loads' do
    sign_in_as(@good_user)
    assert session[:uid]
    get '/settings'
    assert_response :success
  end

  test 'it shows next weekly date' do
    t = Time.zone.local(2019, 3, 1, 10, 5, 0)
    Timecop.freeze(t) do
      sign_in_as(@good_user)
      assert session[:uid]
      get '/settings'
      assert_match(/March 4, 2019/, response.body)
    end
  end

  test 'it shows next monthly date' do
    t = Time.zone.local(2019, 3, 3, 10, 5, 0)
    Timecop.freeze(t) do
      sign_in_as(@monthly_user)
      assert session[:uid]
      get '/settings'
      assert_match(/April 1, 2019/, response.body)
    end
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

  test 'can delete self' do
    assert_difference('User.count', -1) do
      as_user(@good_user) do
        visit '/settings'
        click_button 'Delete Account'
        assert_match(/Sorry/, page.body)
      end
    end
  end
end
