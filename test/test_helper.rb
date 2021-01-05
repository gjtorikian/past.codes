# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

require 'minitest/pride'
require 'sidekiq/testing'
require 'webmock/minitest'
require 'capybara/rails'
require 'capybara/minitest'
require 'minitest/mock_expectations'

Dir[Rails.root.join('test/support/**/*.rb')].sort.each { |f| require f }

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  Sidekiq::Testing.fake!

  WebMock.disable_net_connect!
end

class ActionDispatch::IntegrationTest
  include SignInHelper

  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  # Make `assert_*` methods behave like Minitest assertions
  include Capybara::Minitest::Assertions

  Capybara.app_host = 'http://example.com'

  # Reset sessions and driver between tests
  teardown do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  # cannot for the life of me figure out how to set this env var;
  # without it, all requests attempt to go to the www- version
  # which adds an additional redirect
  ActiveSupport.on_load(:action_dispatch_request) do
    def initialize(env)
      super(env)
      @env['HTTP_HOST'] = @env['HTTP_HOST'].sub(/www\./, '') if @env.present?
    end
  end
end

def stub_get_primary_emails(emails: '', headers: {})
  stub_request(:get, 'https://api.github.com/user/emails')
    .to_return(status: 200, body: emails, headers: headers)
end

def stub_get_introspection_query
  stub_request(:post, 'https://api.github.com/graphql')
    .with(
      body: /query IntrospectionQuery/,
      headers: {
        'Authorization' => 'bearer secretztoken',
        'Content-Type' => 'application/json'
      }
    )
    .to_return(status: 200, body: file_fixture('dummy_introspection_response.json').read, headers: {})
end

def stub_get_starred_repos(res, pagination_query: false)
  stub_get_primary_emails
  stub_get_introspection_query

  query = if pagination_query
            /starredRepositories.+?"after":"Y3Vyc29yOnYyOpK5MjAyMC0xMi0wOVQxNDoyNDoyNCswMDowMM4O8QMK"/
          else
            /starredRepositories.+?"after":null/
          end

  stub_request(:post, 'https://api.github.com/graphql')
    .with(
      body: query,
      headers: {
        'Authorization' => 'bearer secretztoken',
        'Content-Type' => 'application/json'
      }
    )
    .to_return(status: 200, body: res, headers: {})
end
