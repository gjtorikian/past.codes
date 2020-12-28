# frozen_string_literal: true

class SessionsController < ApplicationController
  include ClientHelper

  def new
    # This route is catched by the Omniauth Middleware and is invisible to rake routes
    redirect_to '/auth/github'
  end

  def create
    user_access_token = authorize_params.fetch('credentials').fetch('token')
    encrypted_token = auth_encrypt(user_access_token)

    user = User.find_or_create!(authorize_params, encrypted_token)
    session[:uid] = user.uid
    redirect_to root_path
  end

  def destroy
    session.delete(:uid)
    redirect_to root_path
  end

  private def authorize_params
    request.env.fetch('omniauth.auth')
  end
end
