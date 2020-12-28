# frozen_string_literal: true

class User < ApplicationRecord
  validates :uid, :frequency, :username, :email, :encrypted_gh_token, presence: true

  def self.find_or_create!(authorize_params, encrypted_token)
    user = find_by(uid: authorize_params.fetch('uid'))
    email = authorize_params.fetch('info').fetch('email')

    if user.present?
      user.update(email: email, encrypted_gh_token: encrypted_token)
      return user
    end

    create!(
      uid: authorize_params.fetch('uid'),
      email: authorize_params.fetch('info').fetch('email'),
      username: authorize_params.fetch('info').fetch('nickname'),
      encrypted_gh_token: encrypted_token
    )
  end
end
