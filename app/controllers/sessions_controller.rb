# frozen_string_literal: true

class SessionsController < ApplicationController
  include ClientHelper
  include SessionsHelper

  # This route is made by the Omniauth Middleware and is invisible to rake routes
  def new
    if signed_in?
      redirect_to '/'
    else
      redirect_to '/auth/github'
    end
  end

  def create
    user_access_token = authorize_params.fetch('credentials').fetch('token')
    encrypted_token = auth_encrypt(user_access_token)

    user = User.find_or_create!(authorize_params, encrypted_token)
    session[:uid] = user.github_id

    redirect_to root_path
  end

  def destroy
    reset_session
    redirect_to root_path
  end

  def failure
    flash[:error] = 'There was a problem authenticating with GitHub. Please try again.'
    redirect_to root_path
  end

  private def authorize_params
    request.env.fetch('omniauth.auth')
  end
end
