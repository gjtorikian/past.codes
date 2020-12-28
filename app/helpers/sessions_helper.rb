# frozen_string_literal: true

module SessionsHelper
  def require_login
    return if signed_in?

    redirect_to '/'
  end

  def signed_in?
    session[:uid].present?
  end

  def current_user
    User.find_by!(github_id: session[:uid]) if signed_in?
  end
end
