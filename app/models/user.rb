# frozen_string_literal: true

class User < ApplicationRecord
  validates :github_id, :frequency, :github_username, :encrypted_github_token, presence: true
  enum frequency: { weekly: 0, monthly: 1 }

  def self.find_or_create!(authorize_params, encrypted_github_token)
    user = find_by(github_id: authorize_params.fetch('uid'))

    if user.present?
      user.update(encrypted_github_token: encrypted_github_token)
      return user
    end

    create!(
      github_id: authorize_params.fetch('uid'),
      github_username: authorize_params.fetch('info').fetch('nickname'),
      encrypted_github_token: encrypted_github_token
    )
  end

  def flipper_id
    "#{self.class.name};#{github_username}"
  end
end
