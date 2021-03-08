# frozen_string_literal: true

class StaffController < ApplicationController
  include SessionsHelper

  before_action :require_staff_login

  def index; end

  def require_staff_login
    return render404 unless signed_in?

    # Verify that the user is a staff member
    user = User.find_by(github_id: session[:uid])
    return render404 unless Flipper.enabled?(:dashboard_staff, user)
  end

  # sidekiq needs its own special method
  def self.staff_request?(request)
    return false if request.session[:uid].blank? # needs a login

    user = User.find_by(github_id: request.session[:uid])
    Flipper.enabled?(:dashboard_sidekiq, user)
  end
end
