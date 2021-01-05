# frozen_string_literal: true

OmniAuth.config.test_mode = true

OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
  'provider' => 'github',
  'uid' => 1,
  'info' => { 'nickname' => 'nickname' },
  'credentials' => { 'token' => SecureRandom.hex(20) }
)

module SignInHelper
  def sign_in_as(user)
    auth_details(user)

    get '/signin'
    # https://github.com/digitalocean/hacktoberfest/pull/351
    post '/auth/github' # this clicks the button to /auth/github

    follow_redirect! # this "comes back" from github and goes to /auth/github/callback
    follow_redirect! # now we are at /

    user.reload
  end

  def as_user(user)
    auth_details(user)

    visit '/signin'

    click_on 'Sign in with GitHub'

    yield

    visit '/signout'
  end

  private def auth_details(user)
    OmniAuth.config.mock_auth[:github].uid = user.github_id
    OmniAuth.config.mock_auth[:github].info = { 'nickname' => user.github_username }
    OmniAuth.config.mock_auth[:github].credentials.token = user.encrypted_github_token
  end
end
