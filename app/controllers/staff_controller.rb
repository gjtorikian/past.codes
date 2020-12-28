# frozen_string_literal: true

class StaffController < ApplicationController
  include SessionsHelper

  before_action :require_staff_login

  STAFF_LIST = %w[
    gjtorikian
  ].freeze

  def index; end

  def require_staff_login
    return render404 unless signed_in?

    # Verify that the user is a staff member
    username = User.find_by(github_id: session[:uid]).github_username
    return render404 unless STAFF_LIST.include?(username)
  end

  # sidekiq needs its own special method
  def self.staff_request?(request)
    return false if request.session[:uid].blank? # needs a login

    username = User.find_by(github_id: request.session[:uid]).github_username
    STAFF_LIST.include?(username)
  end
end
