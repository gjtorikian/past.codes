# frozen_string_literal: true

class User < ApplicationRecord
  validates :github_id, :frequency, :github_username, :email_address, :encrypted_gh_token, presence: true
  enum frequency: { weekly: 0, monthly: 1 }

  def self.find_or_create!(authorize_params, encrypted_gh_token)
    user = find_by(github_id: authorize_params.fetch('uid'))
    email = authorize_params.fetch('info').fetch('email')

    if user.present?
      user.update(email_address: email, encrypted_gh_token: encrypted_gh_token)
      return user
    end

    create!(
      github_id: authorize_params.fetch('uid'),
      email_address: email,
      github_username: authorize_params.fetch('info').fetch('nickname'),
      encrypted_gh_token: encrypted_gh_token
    )
  end
end