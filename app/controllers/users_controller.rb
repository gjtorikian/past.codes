# frozen_string_literal: true

class UsersController < ApplicationController
  include SessionsHelper

  def new; end

  before_action :require_login, only: %i[update destroy]

  def update
    id = params[:id].to_i

    return render404 if current_user.id != id

    current_user.update(frequency: params[:user_delivery_type])

    redirect_to '/settings'
  end

  def destroy
    id = params[:id].to_i

    return render404 if current_user.id != id

    current_user.destroy
    reset_session
  end
end
