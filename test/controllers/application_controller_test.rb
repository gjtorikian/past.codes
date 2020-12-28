# frozen_string_literal: true

require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test 'renders a 404' do
    get '/asdasdasdasd'
    assert_response :not_found
    assert_match(/何/, response.body)
  end
end
