# frozen_string_literal: true

module SessionsHelper
  def signed_in?
    session[:uid].present?
  end

  def current_user
    User.find_by!(uid: session[:uid]) if signed_in?
  end
end
