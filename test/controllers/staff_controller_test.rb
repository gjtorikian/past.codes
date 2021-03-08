# frozen_string_literal: true

require 'test_helper'

class StaffControllerTest < ActionDispatch::IntegrationTest
  test 'requires auth' do
    get '/staff'
    assert_response :not_found
  end

  test 'should not allow non-staff' do
    bad_user = users(:bad_user)
    Flipper.disable(:staff, bad_user)
    sign_in_as(bad_user)
    get '/staff'
    assert_response :not_found
  end

  test 'should allow staff' do
    staff = users(:gjtorikian)
    Flipper.enable(:staff, staff)
    sign_in_as(staff)
    get '/staff'
    assert_response :success
  end

  test 'should get sidekiq dashboard' do
    staff = users(:gjtorikian)
    Flipper.enable(:sidekiq_dashboard, staff)
    sign_in_as(staff)
    get '/staff/sidekiq'
    assert_response :success
  end

  test 'should block rando from get sidekiq dashboard' do
    bad_user = users(:bad_user)
    Flipper.disable(:sidekiq_dashboard, bad_user)
    sign_in_as(bad_user)
    get '/staff/sidekiq'
    assert_response :not_found
  end

  test 'should block anonymous from get sidekiq dashboard' do
    get '/staff/sidekiq'
    assert_response :not_found
  end
end
