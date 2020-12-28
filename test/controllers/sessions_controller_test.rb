# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @good_user = users(:good_user)
  end

  test 'GET #new redirects to /auth/github' do
    get '/signin'
    assert_redirected_to '/auth/github'
  end

  test 'GET #new redirects to /root if already logged in' do
    sign_in_as(@good_user)
    get '/signin'
    assert_redirected_to '/'
    assert session[:uid]
  end

  test 'GET #destroy redirects to /' do
    sign_in_as(@good_user)
    assert session[:uid]
    delete '/signout'
    assert_redirected_to '/'
    assert_not session[:uid]
  end

  test 'GET #failure redirects to / and sets a flash message' do
    get '/auth/failure'

    assert_redirected_to '/'
    assert_equal 'There was a problem authenticating with GitHub. Please try again.', flash[:error]
  end
end
