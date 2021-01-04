# frozen_string_literal: true

require 'test_helper'

class ClientHelperTest < ActionDispatch::IntegrationTest
  include ClientHelper

  def setup
    @encrypted_gh_token = auth_encrypt('secretztoken')
  end

  test 'it handles nil and empty headers' do
    stub_get_scope_access(headers: nil)

    assert_equal [], ClientHelper.fetch_scopes(@encrypted_gh_token)

    stub_get_scope_access(headers: {})

    assert_equal [], ClientHelper.fetch_scopes(@encrypted_gh_token)
  end

  test 'it handles empty string header' do
    stub_get_scope_access(headers: { 'x-oauth-scopes': '' })

    assert_equal [], ClientHelper.fetch_scopes(@encrypted_gh_token)
  end

  test 'it handles string header' do
    stub_get_scope_access(headers: { 'x-oauth-scopes': 'foo' })

    assert_equal ['foo'], ClientHelper.fetch_scopes(@encrypted_gh_token)
  end

  test 'it handles string splitting header' do
    stub_get_scope_access(headers: { 'x-oauth-scopes': 'foo, wow' })

    assert_equal %w[foo wow], ClientHelper.fetch_scopes(@encrypted_gh_token)

    stub_get_scope_access(headers: { 'x-oauth-scopes': 'foo,pow' })

    assert_equal %w[foo pow], ClientHelper.fetch_scopes(@encrypted_gh_token)
  end
end
