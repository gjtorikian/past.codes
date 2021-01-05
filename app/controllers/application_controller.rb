# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :current_email

  def render404
    render 'error/404', status: :not_found
  end

  private

  def current_user
    @current_user ||= User.find_by(github_id: session[:uid])
  end

  def current_email
    @current_email ||= GitHubClient.new(current_user.encrypted_github_token).fetch_primary_email_and_scopes[:primary_email]
  end
end
