# frozen_string_literal: true

require 'test_helper'
require 'github_client'

class GitHubClientTest < ActionDispatch::IntegrationTest
  include AuthHelper

  def setup
    @encrypted_github_token = auth_encrypt('secretztoken')
    @gh_client = GitHubClient.new(@encrypted_github_token)
  end

  test 'it handles nil and empty body and headers' do
    stub_get_primary_emails(emails: [], headers: nil)

    h = {
      primary_email: '',
      scopes: []
    }

    assert_equal h, @gh_client.fetch_primary_email_and_scopes

    stub_get_primary_emails(emails: [], headers: {})

    assert_equal h, @gh_client.fetch_primary_email_and_scopes

    stub_get_primary_emails(emails: nil, headers: {})

    assert_equal h, @gh_client.fetch_primary_email_and_scopes
  end

  test 'it handles empty string header' do
    stub_get_primary_emails(emails: [], headers: { 'x-oauth-scopes': '' })

    h = {
      primary_email: '',
      scopes: []
    }

    assert_equal h, @gh_client.fetch_primary_email_and_scopes
  end

  test 'it handles string header' do
    stub_get_primary_emails(emails: [], headers: { 'x-oauth-scopes': 'foo' })

    h = {
      primary_email: '',
      scopes: ['foo']
    }

    assert_equal h, @gh_client.fetch_primary_email_and_scopes
  end

  test 'it handles string splitting header' do
    stub_get_primary_emails(emails: [], headers: { 'x-oauth-scopes': 'foo, wow' })

    h = {
      primary_email: '',
      scopes: %w[foo wow]
    }

    assert_equal h, @gh_client.fetch_primary_email_and_scopes

    stub_get_primary_emails(headers: { 'x-oauth-scopes': 'foo,wow' })

    assert_equal h, @gh_client.fetch_primary_email_and_scopes
  end

  test 'it handles missing primary emails' do
    stub_get_primary_emails(emails: [{ email: 'somewhere@foo.com' }, { email: 'somewhere@else.com', primary: false }], headers: { 'x-oauth-scopes': 'foo, wow' })

    h = {
      primary_email: '',
      scopes: %w[foo wow]
    }

    assert_equal h, @gh_client.fetch_primary_email_and_scopes
  end

  test 'it handles existing primary emails' do
    stub_get_primary_emails(emails: [{ email: 'exists@foo.com', primary: true }, { email: 'somewhere@else.com', primary: false }], headers: { 'x-oauth-scopes': 'foo, wow' })

    h = {
      primary_email: 'exists@foo.com',
      scopes: %w[foo wow]
    }

    assert_equal h, @gh_client.fetch_primary_email_and_scopes
  end
end
